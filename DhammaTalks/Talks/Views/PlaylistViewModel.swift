//
//  PlaylistViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-02-25.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation
import Combine

class PlaylistViewModel: ObservableObject {
    @Published var playlistItems: [TalkRowViewModel] = []
    let title: String
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(title: String,
         playlistItems: [TalkRowViewModel],
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager) {
        self.title = title
        self.playlistItems = playlistItems
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }

    func playRandomTalk() async -> String? {
        return await playlistItems.playRandom()
    }
}
