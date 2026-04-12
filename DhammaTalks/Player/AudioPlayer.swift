//
//  AudioPlayer.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

import AVKit
import Combine
import MediaPlayer
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    
    private var playIndex = 0
    
    private let seekDuration: TimeInterval = 15
    
    weak var playableList: PlayableList?
    
    enum Status {
        case idle
        case playing
        case paused
    }
    
    @Published var status: Status = .idle
    @Published var title: String? = nil
    @Published var progressTime: TimeInterval = 0
    @Published var isActive: Bool = false
    @Published var showProgress: Bool = false
    
    private var playableItems: [any PlayableItem] {
        guard let playableItems = playableList?.playableItems else {
            return []
        }
        return playableItems
    }

    var isScrubbing = false
    
    // TODO: Abstract out AVPlayer so that this code can be more easily mocked for unit testing.
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        periodicTimeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000)),
            queue: DispatchQueue.main,
            using: { [weak self] time in
                self?.progressTime = time.seconds
                self?.setupNowPlayingInfo()
            }
        )
        
        playerObservation = player.observe(\.timeControlStatus, options: [.old, .new]) { [weak self] player, change in
            guard let self else {
                return
            }
            
            switch player.timeControlStatus {
            case .paused:
                status = .paused
            case .playing:
                status = .playing
            default:
                status = .idle
            }
        }
        
        return player
    }()

    private let networkMonitor: NetworkMonitoring

    private var currentPlayerItem: AVPlayerItem? {
        player.currentItem
    }
    
    private var currentPlayableItem: (any PlayableItem)? {
        guard playableItems.indices.contains(playIndex) else {
            return nil
        }
        return playableItems[playIndex]
    }
    
    private var periodicTimeObserver: Any?
    private var playerObservation: NSKeyValueObservation?
    private let dispatcher: Dispatcher

    init(networkMonitor: NetworkMonitoring = NetworkMonitor(), dispatcher: Dispatcher = DispatchQueue.main) {
        self.networkMonitor = networkMonitor
        self.dispatcher = dispatcher
        super.init()
        setupInterruptionNotification()
        setupRemoteTransportControls()
    }
    
    deinit {
        if let periodicTimeObserver {
            self.player.removeTimeObserver(periodicTimeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor
    func play(at index: Int = 0) async {
        
        guard playableItems.indices.contains(index) else {
            return
        }
        
        showProgress = false
        if status != .paused || index != playIndex {
            playIndex = index
            guard let playableItem = currentPlayableItem else { return }
            if let currentTimeSeconds = playableItem.currentTime?.seconds {
                self.progressTime = currentTimeSeconds
            }
            let playerItem = await playableItem.loadPlayerItem()
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinishPlaying(sender:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            player.replaceCurrentItem(with: playerItem)
            title = playableItem.title
            setupInterruptionNotification()
            setupRemoteTransportControls()
            setupNowPlayingInfo()
        }
        player.play()
        self.isActive = true
        // This helps hide the initial jump of the slider thumb when it's re-adjusted for a new talk
        dispatcher.asyncAfter(deadline: .now() + 0.1, execute: {
            self.showProgress = true
        })
    }
    
    func play() async {
        await play(at: playIndex)
    }
    
    private var shouldPlayNext: Bool {
        guard AppSettings.autoplay else {
            return false
        }

        return networkMonitor.isWifi || (networkMonitor.isCellular && AppSettings.useCellularData)
    }
    
    @MainActor
    @objc func playerDidFinishPlaying(sender: Notification) {
        Task {
            let playNext = if shouldPlayNext { await playNext() } else { false }
            if !playNext {
                isActive = false
                finish()
            }
        }
    }
    
    func pause() {
        player.pause()
    }
    
    @MainActor
    func finish() {
        player.pause()
        isScrubbing = false
        NotificationCenter.default.removeObserver(self)
        removeRemoteTransportControls()
        clearNowPlayingInfo()
        progressTime = 0
        status = .idle
        if let currentPlayableItem, let currentPlayerItem {
            currentPlayableItem.finishedPlaying(at: currentPlayerItem.currentTime(),
                                                withTotal: currentPlayerItem.duration)
        }
    }
    
    func skipForward() {
        guard let currentPlayerItem else { return }
        let duration = CMTimeGetSeconds(currentPlayerItem.duration)
        guard !duration.isNaN else { return } // Happens in airplane mode with no talk data
        let playerCurrentTime = CMTimeGetSeconds(currentPlayerItem.currentTime())
        guard !playerCurrentTime.isNaN else { return }
        let newTime = playerCurrentTime + seekDuration
        seekTo(seconds: newTime <= duration ? newTime : duration)
    }
    
    func skipBackward() {
        guard let currentPlayerItem else { return }
        let playerCurrentTime = CMTimeGetSeconds(currentPlayerItem.currentTime())
        var newTime = playerCurrentTime - seekDuration
        if newTime < 0 {
            newTime = 0
        }
        seekTo(seconds: newTime.lowerBoundedValue())
    }
    
    func seekTo(seconds: TimeInterval) {
        let seekToTime = CMTimeMake(value: Int64(seconds * 1000 as Float64),
                                    timescale: 1000)
        player.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    var showPlayButton: Bool {
        status != .playing
    }

    var hasNext: Bool {
        playableItems.indices.contains(playIndex + 1)
    }

    var hasPrevious: Bool {
        playIndex > 0 && playableItems.indices.contains(playIndex - 1)
    }
    
    private var currentTimeInSeconds: TimeInterval {
        if isScrubbing {
            return progressTime.lowerBoundedValue()
        } else {
            guard let currentTime = currentPlayerItem?.currentTime(), currentTime.timescale > 0 else {
                return 0
            }
            return TimeInterval(currentTime.value)/TimeInterval(currentTime.timescale)
        }
    }
    
    var totalTimeInSeconds: TimeInterval {
        guard let totalTime = currentPlayerItem?.duration, totalTime.timescale > 0 else {
            return 0
        }
        return TimeInterval(totalTime.value)/TimeInterval(totalTime.timescale)
    }
    
    var currentTimeString: String? {
        DateComponentsFormatter.hmsFormatter.string(from: currentTimeInSeconds > 0 ? currentTimeInSeconds : 0)
    }
    
    var totalTimeString: String? {
        guard let totalTime = DateComponentsFormatter.hmsFormatter.string(from: totalTimeInSeconds) else {
            return nil
        }
        return totalTime
    }

    @MainActor
    func playNext() async -> Bool {
        if hasNext {
            finish()
            await play(at: playIndex + 1)
            return true
        }
        return false
    }
    
    @MainActor
    func playPrevious() async -> Bool {
        if hasPrevious {
            finish()
            await play(at: playIndex - 1)
            return true
        }
        return false
    }
    
    // MARK: Private functions

    func setupInterruptionNotification() {
        // Register for notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            pause()
            
        case .ended:
            // Interruption ended: Check if we should resume
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume playback
                    Task {
                        await play()
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    // Handlers for the remote commands
    @objc func handlePlayCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if status != .playing {
            Task {
                await play()
            }
            return .success
        }
        return .commandFailed
    }
    
    @objc func handlePauseCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if status == .playing {
            pause()
            return .success
        }
        return .commandFailed
    }
    
    @objc func handleChangePlaybackPositionCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let changePlaybackPositionCommandEvent =
                event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }

        let positionTime = changePlaybackPositionCommandEvent.positionTime
        let seekToTime = CMTimeMake(value: Int64(positionTime * 1000 as Float64),
                                    timescale: 1000)
        player.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        return .success
    }
    
    @objc func handleSkipForwardCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        skipForward()
        return .success
    }
    
    @objc func handleSkipBackwardCommand(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        skipBackward()
        return .success
    }
}

// MARK: - Remote Command Center

extension AudioPlayer {

    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(handlePlayCommand(event:)))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(handlePauseCommand(event:)))
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(handleChangePlaybackPositionCommand(event:)))
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget(self, action: #selector(handleSkipForwardCommand(event:)))
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget(self, action: #selector(handleSkipBackwardCommand(event:)))
    }
    
    private func removeRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        commandCenter.skipForwardCommand.removeTarget(self)
        commandCenter.skipBackwardCommand.removeTarget(self)
    }
}

// MARK: - Now Playing Info

extension AudioPlayer {
    
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        if let image = UIImage(named: "dtLogo-transparent") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentPlayerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

private extension TimeInterval {

    private static let lowerBound: TimeInterval = 0.1

    func lowerBoundedValue() -> TimeInterval {
        self <= 0 ? Self.lowerBound : self
    }
}

