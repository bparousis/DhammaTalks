//
//  FavoritesListViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-06.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import Combine

class FavoritesListViewModel: ObservableObject {
    @Published var favorites: [TalkRowViewModel] = []
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    private let playlistService: PlaylistService
    
    var playAtIndex: Int = 0
    private let playSubject = PassthroughSubject<String, Never>()

    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService)
    {
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.playlistService = playlistService
    }
    
    @MainActor
    func fetchFavorites(searchText: String) async {
        favorites = await talkUserInfoService.fetchFavoriteTalks(searchText: searchText)
            .map{ createTalkRowViewModel(talkData: $0) }
    }
    
    private func createTalkRowViewModel(talkData: TalkData) -> TalkRowViewModel {
        let viewModel = TalkRowViewModel(talkData: talkData,
                                         talkUserInfoService: talkUserInfoService,
                                         downloadManager: downloadManager,
                                         playlistService: playlistService,
                                         playSubject: playSubject)
        viewModel.dateStyle = .full
        return viewModel
    }
    
    func playRandomTalk() -> String? {
        return favorites.playRandom()
    }
}

extension FavoritesListViewModel: PlayableList {
    var playableItems: [any PlayableItem] {
        favorites
    }
    
    var playPublisher: AnyPublisher<String, Never> {
        playSubject.eraseToAnyPublisher()
    }
}
