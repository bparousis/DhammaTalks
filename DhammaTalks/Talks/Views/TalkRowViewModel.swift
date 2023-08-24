//
//  TalkRowViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-30.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import Combine
import AVFoundation
import os.log

class TalkRowViewModel: NSObject, Identifiable, ObservableObject {

    enum DateStyle {
        case day
        case full
        case noDay
    }
    
    enum Action: String, Identifiable {
        var id: RawValue { rawValue }
        
        case download
        case removeDownload
        case addToFavorites
        case removeFromFavorites
        case notes
        case transcript
        case addToPlaylist
        case removeFromPlaylist
        
        var title: String {
            switch self {
            case .download: return "Download"
            case .removeDownload: return "Remove Download"
            case .addToFavorites: return "Add to Favorites"
            case .removeFromFavorites: return "Remove from Favorites"
            case .notes: return "Notes"
            case .transcript: return "Transcript"
            case .addToPlaylist: return "Add to Playlist"
            case .removeFromPlaylist: return "Remove from Playlist"
            }
        }
    }
    
    enum TalkState {
        case unplayed
        case played
        case inProgress
    }

    private let talkData: TalkData
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    private let playlistService: PlaylistService
    private let playSubject: any Subject<String, Never>
    var playlist: Playlist?

    private static let PLAYED_TIME_BUFFER: TimeInterval = 10
    var dateStyle: DateStyle = .day
    private var downloadJob: DownloadJob? {
         didSet {
             cancellable = downloadJob?.downloadProgressPublisher
                 .receive(on: DispatchQueue.main)
                 .sink{ value in
                     self.downloadProgress = value
                 }
        }
    }
    private var cancellable: AnyCancellable?

    private var currentTime: CMTime? {
        didSet {
            updateState()
        }
    }

    private var totalTime: CMTime? {
        didSet {
            updateState()
        }
    }
    
    var actions: [Action] {
        var actionList: [Action] = []
        actionList.append(favorite ? .removeFromFavorites : .addToFavorites)
        actionList.append(isInPlaylist ? .removeFromPlaylist : .addToPlaylist)
        actionList.append(isDownloadAvailable ? .removeDownload : .download)
        
        actionList.append(.notes)
        if talkData.transcribeURL != nil {
            actionList.append(.transcript)
        }
        return actionList
    }
    
    var id: String {
        talkData.id
    }
    
    var transcribeURL: URL? {
        talkData.transcribeURL
    }

    var isDownloadAvailable: Bool {
        downloadManager.isDownloadAvailable(filename: talkData.filename)
    }
    
    var isInPlaylist: Bool {
        playlist != nil
    }
    
    var formattedDate: String? {
        guard let date = talkData.date else {
            return nil
        }
        return DateFormatter.monthDayYearFormatter.string(from: date)
    }
    
    var formattedDay: String? {
        guard let date = talkData.date else {
            return nil
        }
        return DateFormatter.dayFormatter.string(from: date)
    }
    
    var currentTimeInSeconds: TimeInterval {
        guard let currentTime = currentTime, currentTime.timescale > 0 else {
            return 0
        }
        return TimeInterval(currentTime.value)/TimeInterval(currentTime.timescale)
    }
    
    var totalTimeInSeconds: TimeInterval {
        guard let totalTime = totalTime, totalTime.timescale > 0 else {
            return 0
        }
        return TimeInterval(totalTime.value)/TimeInterval(totalTime.timescale)
    }
    
    var currentTimeString: String? {
        guard currentTimeInSeconds > 0 else { return nil }
        return DateComponentsFormatter.hmsFormatter.string(from: currentTimeInSeconds)
    }
    
    var timeRemainingString: String? {
        guard currentTimeInSeconds > 0, totalTimeInSeconds > 0, let timeRemaining = DateComponentsFormatter.hmsFormatter.string(from: totalTimeInSeconds - currentTimeInSeconds) else {
            return nil
        }
        return "-\(timeRemaining)"
    }

    @Published var state: TalkState = .unplayed
    @Published var downloadProgress: CGFloat?
    @Published var favorite = false
    @Published var showNotes = false
    @Published var showTranscript = false
    @Published var showPlaylistSelector = false
    @Published var notes: String = ""
    @Published var playlists: [Playlist] = []
    
    init(talkData: TalkData,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService,
         playSubject: any Subject<String, Never>)
    {
        self.talkData = talkData
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.dateStyle = talkData.showDay ? .day : .noDay
        self.playlistService = playlistService
        self.playSubject = playSubject
    }
    
    func saveNotes() {
        do {
            var talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
            talkUserInfo.notes = notes
            try talkUserInfoService.save(talkUserInfo: talkUserInfo)
        } catch {
            Logger.talkUserInfo.error("Error saving TalkUserInfo: \(String(describing: error))")
        }
    }
    
    @MainActor
    func fetchPlaylists() async {
        playlists = await playlistService.fetchPlaylists()
    }

    func addToPlaylist(_ playlist: Playlist) {
        _ = try? playlistService.addTalkData(talkData, toPlaylistWithID: playlist.id)
    }
    
    func createPlaylist(title: String, description: String?) {
        do {
            let playlist = Playlist(id: UUID(),
                                    title: title,
                                    desc: description,
                                    playlistItems: [])
            try playlistService.createPlaylist(playlist)
        } catch {
            Logger.playlist.error("Error saving Playlist: \(String(describing: error))")
        }
    }

    func play() {        
        playSubject.send(id)
    }

    func finishedPlaying(item: AVPlayerItem) {
        
        // playerItem can only be associated with a single AVPlayer.  So when we're finished playing we
        // need to set it to nil.  A new instance will be created the next time the talk is played.
        currentTime = item.currentTime()
        totalTime = item.duration

        do {
            var talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
            talkUserInfo.currentTime = item.currentTime()
            talkUserInfo.totalTime = item.duration
            try talkUserInfoService.save(talkUserInfo: talkUserInfo)
        } catch {
            Logger.talkUserInfo.error("Error saving TalkUserInfo: \(String(describing: error))")
        }
    }
    
    func didShowTranscript() {
        // Toggle back to false so that it can be triggered again.
        showTranscript = false
    }

    func handleAction(_ action: Action) {
        switch action {
        case .download:
            performDownload()
        case .removeDownload:
            removeDownload()
        case .addToFavorites:
            setFavorite(to: true)
        case .removeFromFavorites:
            setFavorite(to: false)
        case .notes:
            showNotes = true
        case .transcript:
            showTranscript = true
        case .addToPlaylist:
            showPlaylistSelector = true
        case .removeFromPlaylist:
            //TODO: Implement
            break
        }
    }
    
    func fetchTalkInfo() {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
            favorite = talkUserInfo.isFavorite
            notes = talkUserInfo.notes ?? ""
        }
        self.downloadJob = downloadManager.findDownloadJob(for: talkData)
    }
    
    func cancelDownload() {
        downloadJob?.cancel()
    }
    
    func applyFilter(_ filter: Filter) -> Bool {
        switch filter {
        case .empty:
            return true
        case .downloaded:
            return isDownloadAvailable
        case .hasNotes:
            let talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
            return talkUserInfo.hasNotes
        case .favorited:
            let talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
            return talkUserInfo.isFavorite
        }
    }

    // MARK: Private

    private func fetchOrCreateTalkUserInfo(for url: String) -> TalkUserInfo {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            return talkUserInfo
        } else {
            return TalkUserInfo(url: talkData.url, currentTime: CMTime(), totalTime: CMTime())
        }
    }

    private func performDownload() {
        downloadJob = downloadManager.createDownloadJob(for: talkData)
        downloadJob?.start()
    }

    private func setFavorite(to value: Bool) {
        var talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
        talkUserInfo.favoriteDetails = value ? FavoriteDetails(title: talkData.title, dateAdded: Date()) : nil
        do {
            try talkUserInfoService.save(talkUserInfo: talkUserInfo)
            favorite = value
        } catch {
            Logger.talkUserInfo.error("Error setting favorite value: \(String(describing: error))")
        }
    }

    private func removeDownload() {
        downloadManager.removeDownload(filename: talkData.filename)
    }
    
    private func updateState() {
        if currentTimeInSeconds > 0 && totalTimeInSeconds > 0 {
            state = currentTimeInSeconds >= (totalTimeInSeconds - Self.PLAYED_TIME_BUFFER) ? .played : .inProgress
        } else {
            state = .unplayed
        }
    }
}

extension TalkRowViewModel: PlayableItem {

    var title: String {
        talkData.title
    }

    func loadPlayerItem() async -> AVPlayerItem? {
        guard let playItemURL = downloadManager.downloadURL(for: talkData.filename) ?? talkData.makeURL() else {
            return nil
        }

        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
        }
        
        let playerItem = AVPlayerItem(url: playItemURL)
        if var currentTime = currentTime, currentTimeInSeconds > 0 {
            if state == .played {
                // If it's played then start it from the beginning again.
                currentTime = CMTime(seconds: 0, preferredTimescale: currentTime.timescale)
                self.currentTime = currentTime
            }
            await playerItem.seek(to: currentTime)
        }
        return playerItem
    }
    
    func finishedPlaying(at time: CMTime, withTotal totalTime: CMTime) {
        // At least one second should have been played before we bother
        // recording the current time.
        guard time.seconds > 1 else {
            return
        }
        self.currentTime = time
        self.totalTime = totalTime

        do {
            var talkUserInfo = fetchOrCreateTalkUserInfo(for: talkData.url)
            talkUserInfo.currentTime = time
            talkUserInfo.totalTime = totalTime
            try talkUserInfoService.save(talkUserInfo: talkUserInfo)
        } catch {
            Logger.talkUserInfo.error("Error saving TalkUserInfo: \(String(describing: error))")
        }
    }
}
