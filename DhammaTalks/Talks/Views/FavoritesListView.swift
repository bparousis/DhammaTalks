//
//  FavoritesListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-10.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

import SwiftUI
import CoreData
import Combine

struct FavoritesListView: View {

    @ObservedObject private var viewModel: FavoritesListViewModel
    private var talkUserInfoService: TalkUserInfoService {
        viewModel.talkUserInfoService
    }

    init(viewModel: FavoritesListViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var favoritesListView: some View {
        if viewModel.favorites.isEmpty {
            Text("No favorites")
        } else {
            List {
                ForEach(viewModel.favorites) { favoriteTalkData in
                    TalkRow(viewModel: createTalkRowViewModel(talkData: favoriteTalkData))
                }
            }
        }
    }
    
    var body: some View {
        favoritesListView
        .onReceive(talkUserInfoService.savePublisher) { output in
            if output.favorite == false {
                Task {
                    await viewModel.fetchFavorites()
                }
            }
        }
        .task {
            await viewModel.fetchFavorites()
        }
        .navigationTitle("Favorites")
    }
    
    private func createTalkRowViewModel(talkData: TalkData) -> TalkRowViewModel {
        let viewModel = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        viewModel.dateStyle = .full
        return viewModel
    }
}


class FavoritesListViewModel: ObservableObject {
    @Published var favorites: [TalkData] = []
    let talkUserInfoService: TalkUserInfoService
    
    init(talkUserInfoService: TalkUserInfoService) {
        self.talkUserInfoService = talkUserInfoService
    }
    
    func fetchFavorites() async {
        favorites = await talkUserInfoService.fetchFavoriteTalks()
    }
}
