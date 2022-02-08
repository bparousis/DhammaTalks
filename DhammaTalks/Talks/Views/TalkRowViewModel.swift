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
    }
    
    enum Action: String, Identifiable {
        var id: RawValue { rawValue }
        
        case download
        case removeDownload
        case addToFavorites
        case removeFromFavorites
        
        var title: String {
            switch self {
            case .download: return "Download"
            case .removeDownload: return "Remove Donwload"
            case .addToFavorites: return "Add to Favorites"
            case .removeFromFavorites: return "Remove from Favorites"
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
        actionList.append(isDownloadAvailable ? .removeDownload : .download)
        actionList.append(favorite ? .removeFromFavorites : .addToFavorites)
        return actionList
    }
    
    var title: String {
        talkData.title
    }
    
    var id: String {
        talkData.id
    }
    
    var isDownloadAvailable: Bool {
        downloadManager.isDownloadAvailable(filename: talkData.filename)
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
        guard let timeRemaining = DateComponentsFormatter.hmsFormatter.string(from: totalTimeInSeconds - currentTimeInSeconds) else {
            return nil
        }
        return "-\(timeRemaining)"
    }
    

    @Published var playerItem: AVPlayerItem?
    @Published var state: TalkState = .unplayed
    @Published var downloadProgress: CGFloat?
    @Published var favorite: Bool = false
    
    init(talkData: TalkData, talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager)
    {
        self.talkData = talkData
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }

    func play() async {

        guard let playItemURL = downloadManager.downloadURL(for: talkData.filename) ?? talkData.makeURL() else { return }

        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
        }
        
        

        self.playerItem = AVPlayerItem(url: playItemURL)
        if var currentTime = currentTime, currentTimeInSeconds > 0 {
            if state == .played {
                // If it's played then start it from the beginning again.
                currentTime = CMTime(seconds: 0, preferredTimescale: currentTime.timescale)
                self.currentTime = currentTime
            }
            await playerItem?.seek(to: currentTime)
        }
    }
    
    func finishedPlaying(item: AVPlayerItem) {
        
        // playerItem can only be associated with a single AVPlayer.  So when we're finished playing we
        // need to set it to nil.  A new instance will be created the next time the talk is played.
        defer {
            playerItem = nil
        }

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

    func handleAction(_ action: Action) {
        switch action {
        case .download:
            performDownload()
        case .removeDownload:
            removeDownload()
        case .addToFavorites:
            addToFavorites()
        case .removeFromFavorites:
            removeFromFavorites()
        }
    }
    
    func fetchTalkInfo() {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
            favorite = talkUserInfo.isFavorite
        }
        self.downloadJob = downloadManager.findDownloadJob(for: talkData)
    }
    
    func cancelDownload() {
        downloadJob?.cancel()
    }
    
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
    
    private func addToFavorites() {
        setFavorite(to: true)
    }

    private func removeFromFavorites() {
        setFavorite(to: false)
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
