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
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager) {
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }
    
    @MainActor
    func fetchFavorites(searchText: String) async {
        favorites = await talkUserInfoService.fetchFavoriteTalks(searchText: searchText)
            .map{ createTalkRowViewModel(talkData: $0) }
    }
    
    private func createTalkRowViewModel(talkData: TalkData) -> TalkRowViewModel {
        let viewModel = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        viewModel.dateStyle = .full
        return viewModel
    }
    
    func playRandomTalk() async -> String? {
        return await favorites.playRandom()
    }
}
