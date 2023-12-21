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
    private let playSubject = PassthroughSubject<String, Never>()
    var playAtIndex: Int = 0
    
    var title: String {
        playlist.title
    }
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(playlist: Playlist,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService)
    {
        self.playlist = playlist
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.playlistService = playlistService
        
        self.playlistItems = playlist
            .playlistItems
            .sorted { $0.order < $1.order }
            .map{
                let viewModel = TalkRowViewModel(talkData: $0.talkData,
                                                 talkUserInfoService: talkUserInfoService,
                                                 downloadManager: downloadManager,
                                                 playlistService: playlistService,
                                                 playSubject: playSubject)
                viewModel.dateStyle = .full
                viewModel.playlist = playlist
                return viewModel
            }
    }

    func playRandomTalk() -> String? {
        return playlistItems.playRandom()
    }
}

extension PlaylistViewModel: PlayableList {
    var playableItems: [any PlayableItem] {
        playlistItems
    }

    var playPublisher: AnyPublisher<String, Never> {
        playSubject.eraseToAnyPublisher()
    }
}
