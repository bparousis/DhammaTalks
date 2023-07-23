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
    private let playlist: Playlist
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    private let playlistService: PlaylistService
    
    var title: String {
        playlist.title
    }
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(playlist: Playlist,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService) {
        self.playlist = playlist
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.playlistService = playlistService
        
        self.playlistItems = playlist.playlistItems
            .sorted { $0.order < $1.order }
            .map{
                let viewModel = TalkRowViewModel(talkData: $0.talkData,
                                                 talkUserInfoService: talkUserInfoService,
                                                 downloadManager: downloadManager,
                                                 playlistService: playlistService)
                viewModel.dateStyle = .full
                viewModel.playlist = playlist
                return viewModel
            }
    }

    func playRandomTalk() async -> String? {
        return await playlistItems.playRandom()
    }
}
