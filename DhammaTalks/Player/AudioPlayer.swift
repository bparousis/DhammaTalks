//
//  AudioPlayer.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 7/21/23.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import AVKit
import Combine
import MediaPlayer

class AudioPlayer: ObservableObject {
    
    private var playIndex = 0
    
    private let seekDuration: TimeInterval = 15
    
    enum Status {
        case idle
        case playing
        case paused
    }
    
    @Published var status: Status = .idle
    @Published var title: String? = nil
    @Published var progressTime: TimeInterval = 0
    
    var playableItems: () -> [any PlayableItem]
    var isScrubbing = false
    
    private var player: AVPlayer?
    private var currentPlayerItem: AVPlayerItem? {
        player?.currentItem
    }
    
    private var currentPlayableItem: (any PlayableItem)? {
        guard playableItems().indices.contains(playIndex) else {
            return nil
        }
        return playableItems()[playIndex]
    }
    
    private var periodicTimeObserver: Any?
    
    init(playableItems: @escaping () -> [any PlayableItem]) {
        self.playableItems = playableItems
        setupRemoteTransportControls()
    }
    
    deinit {
        if let periodicTimeObserver {
            self.player?.removeTimeObserver(periodicTimeObserver)
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor
    func play(at index: Int = 0) async {

        if status != .paused || index != playIndex {
            let playableItems = playableItems()
            playIndex = index
            guard playableItems.indices.contains(playIndex) else { return }
            let playableItem = playableItems[playIndex]
            let playerItem = await playableItem.loadPlayerItem()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinishPlaying(sender:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
                periodicTimeObserver = self.player?.addPeriodicTimeObserver(
                    forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000)),
                    queue: DispatchQueue.main,
                    using: { time in
                        self.progressTime = time.seconds
                        self.setupNowPlayingInfo()
                    }
                )
            } else {
                player?.replaceCurrentItem(with: playerItem)
            }
            title = playableItem.title
            setupNowPlayingInfo()
        }
        player?.play()
        status = .playing
    }
    
    func play() async {
        await play(at: playIndex)
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        Task {
            let result = await playNext()
            if !result {
                finishPlaying()
            }
        }
    }
    
    func pause() {
        guard status == .playing else { return }
        player?.pause()
        status = .paused
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
        player?.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    var showPlayButton: Bool {
        status != .playing || isScrubbing
    }

    var hasNext: Bool {
        playableItems().indices.contains(playIndex + 1)
    }

    var hasPrevious: Bool {
        playIndex > 0 && playableItems().indices.contains(playIndex - 1)
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
    
    var timeRemainingString: String? {
        guard let timeRemaining = DateComponentsFormatter.hmsFormatter.string(from: totalTimeInSeconds - currentTimeInSeconds) else {
            return nil
        }
        return "-\(timeRemaining)"
    }

    @MainActor
    func playNext() async -> Bool {
        if hasNext {
            finishPlaying()
            await play(at: playIndex + 1)
            return true
        }
        return false
    }
    
    @MainActor
    func playPrevious() async -> Bool {
        if hasPrevious {
            finishPlaying()
            await play(at: playIndex - 1)
            return true
        }
        return false
    }

    func finishPlaying() {
        guard status != .idle else { return }
        pause()
        NotificationCenter.default.removeObserver(self)
        if let currentPlayableItem, let currentPlayerItem {
            currentPlayableItem.finishedPlaying(at: currentPlayerItem.currentTime(),
                                                withTotal: currentPlayerItem.duration)
        }
    }
    
    // MARK: Private functions
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }
            
            if self.status != .playing {
                Task {
                    await self.play()
                }
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }

            if self.status == .playing {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }
            Task {
                await self.playNext()
            }
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self else { return .commandFailed }
            Task {
                await self.playPrevious()
            }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let self, let changePlaybackPositionCommandEvent =
                    event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            let positionTime = changePlaybackPositionCommandEvent.positionTime
            let seekToTime = CMTimeMake(value: Int64(positionTime * 1000 as Float64),
                                        timescale: 1000)
            self.player?.seek(to: seekToTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            return .success
        }
    }
    
    
    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        if let image = UIImage(named: "dtLogo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentPlayerItem?.asset.duration.seconds
        if let player {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

private extension TimeInterval {

    private static let lowerBound: TimeInterval = 0.1

    func lowerBoundedValue() -> TimeInterval {
        self <= 0 ? Self.lowerBound : self
    }
}
