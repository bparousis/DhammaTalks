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

class TalkRowViewModel: ObservableObject {
    
    enum TalkState {
        case unplayed
        case played
        case inProgress
    }

    private let talkData: TalkData
    private let talkUserInfoService: TalkUserInfoService
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

    @Published var playerItem: AVPlayerItem?
    @Published var starred: Bool = false
    @Published var state: TalkState = .unplayed
    
    init(talkData: TalkData, talkUserInfoService: TalkUserInfoService) {
        self.talkData = talkData
        self.talkUserInfoService = talkUserInfoService
    }
    
    var title: String {
        talkData.title
    }
    
    var formattedDate: String? {
        guard let date = talkData.date else {
            return nil
        }
        return DateFormatter.monthDayYearFormatter.string(from: date)
    }

    func play() async {
        if let url = talkData.makeURL() {
            if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
                currentTime = talkUserInfo.currentTime
                totalTime = talkUserInfo.totalTime
            }

            self.playerItem = AVPlayerItem(url: url)
            if let currentTime = currentTime, currentTimeInSeconds > 0 {
                await playerItem?.seek(to: currentTime)
            }
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
            if var talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
                talkUserInfo.currentTime = item.currentTime()
                talkUserInfo.totalTime = item.duration
                try talkUserInfoService.save(talkUserInfo: talkUserInfo)
            } else {
                let userInfo = TalkUserInfo(url: talkData.url, currentTime: item.currentTime(), totalTime: item.duration, starred: false, downloadPath: nil)
                try talkUserInfoService.save(talkUserInfo: userInfo)
            }
        } catch {
            Logger.talkUserInfo.error("Error saving TalkUserInfo: \(String(describing: error))")
        }
    }
    
    func fetchTalkTime() {
        if let talkUserInfo = talkUserInfoService.getTalkUserInfo(for: talkData.url) {
            currentTime = talkUserInfo.currentTime
            totalTime = talkUserInfo.totalTime
        }
    }
    
    private func updateState() {
        if currentTimeInSeconds > 0 && totalTimeInSeconds > 0 {
            state = currentTimeInSeconds >= (totalTimeInSeconds - Self.PLAYED_TIME_BUFFER) ? .played : .inProgress
        } else {
            state = .unplayed
        }
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
}
