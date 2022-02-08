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
    @State var searchText: String = ""

    init(viewModel: FavoritesListViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var favoritesListView: some View {
        if viewModel.favorites.isEmpty && searchText.isEmpty {
            Text("No favorites")
        } else {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.favorites) { favoriteRow in
                        TalkRow(viewModel: favoriteRow)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            Task {
                                if let id = await viewModel.playRandomTalk() {
                                    proxy.scrollTo(id)
                                }
                            }
                        } label: {
                            VStack {
                                Image(systemName: "shuffle")
                                Text("Play")
                            }
                        }
                    }
                }
                .searchable(text: $searchText)
            }
        }
    }
    
    var body: some View {
        favoritesListView
        .onReceive(viewModel.savePublisher) { output in
            if !output.isFavorite {
                Task {
                    await viewModel.fetchFavorites(searchText: searchText)
                }
            }
        }
        .task {
            await viewModel.fetchFavorites(searchText: searchText)
        }
        .task(id: searchText) {
            await viewModel.fetchFavorites(searchText: searchText)
        }
        .navigationTitle("Favorites")
    }
}
