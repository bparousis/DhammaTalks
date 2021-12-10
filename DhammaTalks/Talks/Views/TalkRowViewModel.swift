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


class TalkRowViewModel: NSObject, ObservableObject {

    enum Action: String, Identifiable {
        var id: RawValue { rawValue }
        
        case download
        case removeDownload
        case addToFavorites
        
        var title: String {
            switch self {
            case .download: return "Download"
            case .removeDownload: return "Remove Donwload"
            case .addToFavorites: return "Add to Favorites"
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
    private let urlSession: URLSession
    private let fileStorage: FileStorage
    private static let PLAYED_TIME_BUFFER: TimeInterval = 10

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
        actionList.append(.addToFavorites)
        return actionList
    }
    
    var title: String {
        talkData.title
    }
    
    var isDownloadAvailable: Bool {
        fileStorage.exists(filename: talkData.filename)
    }
    
    var formattedDate: String? {
        guard let date = talkData.date else {
            return nil
        }
        return DateFormatter.monthDayYearFormatter.string(from: date)
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
    
    var timeRemainingPhrase: String? {
        DateComponentsFormatter.timeRemainingPhraseFormatter.string(from: totalTimeInSeconds - currentTimeInSeconds)
    }
    

    @Published var playerItem: AVPlayerItem?
    @Published var state: TalkState = .unplayed
    @Published var downloadProgress: CGFloat?

    private var downloadTask: URLSessionDownloadTask?
    
    init(talkData: TalkData, talkUserInfoService: TalkUserInfoService, urlSession: URLSession = .shared,
         fileStorage: FileStorage = LocalFileStorage())
    {
        self.talkData = talkData
        self.talkUserInfoService = talkUserInfoService
        self.urlSession = urlSession
        self.fileStorage = fileStorage
    }

    func play() async {
        var playItemURL: URL?

        if fileStorage.exists(filename: talkData.filename) {
            playItemURL = fileStorage.createURL(for: talkData.filename)
        } else {
            playItemURL = talkData.makeURL()
        }
        
        guard let url = playItemURL else { return }

        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
        }

        self.playerItem = AVPlayerItem(url: url)
        if let currentTime = currentTime, currentTimeInSeconds > 0 {
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
        }
    }
    
    func fetchTalkTime() {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
        }
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        downloadProgress = nil
    }
    
    private func fetchOrCreateTalkUserInfo(for url: String) -> TalkUserInfo {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            return talkUserInfo
        } else {
            return TalkUserInfo(url: talkData.url, currentTime: CMTime(), totalTime: CMTime())
        }
    }

    private func performDownload() {
        if let downloadURL = talkData.makeURL() {
            downloadTask = urlSession.downloadTask(with: downloadURL)
            downloadTask?.delegate = self
            downloadTask?.resume()
        }
    }

    private func addToFavorites() {
        //TODO: Implement feature
    }
    
    private func removeDownload() {
        do {
            try fileStorage.remove(filename: talkData.filename)
        } catch {
            Logger.fileStorage.error("Failed to remove download: \(String(describing: error))")
        }
    }
    
    private func updateState() {
        if currentTimeInSeconds > 0 && totalTimeInSeconds > 0 {
            state = currentTimeInSeconds >= (totalTimeInSeconds - Self.PLAYED_TIME_BUFFER) ? .played : .inProgress
        } else {
            state = .unplayed
        }
    }
}

extension TalkRowViewModel: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try fileStorage.save(at: location, withFilename: talkData.filename)
        } catch {
            Logger.fileStorage.error("Failed to save download: \(String(describing: error))")
        }
        
        DispatchQueue.main.async {
            self.downloadProgress = nil
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if totalBytesExpectedToWrite > 0 {
            DispatchQueue.main.async {
                self.downloadProgress = CGFloat(totalBytesWritten)/CGFloat(totalBytesExpectedToWrite)
            }
        }
    }
}
