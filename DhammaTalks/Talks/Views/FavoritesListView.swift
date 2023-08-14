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
    private let audioPlayer: AudioPlayer
    @State var searchText: String = ""
    @State var showPlayer: Bool = false

    init(viewModel: FavoritesListViewModel)
    {
        self.viewModel = viewModel
        self.audioPlayer = AudioPlayer {
            viewModel.playableItems
        }
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
                            if let id = viewModel.playRandomTalk() {
                                proxy.scrollTo(id)
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
        .onReceive(viewModel.playPublisher) { playId in
            if let foundIndex = viewModel.findIndexOfPlayableItemWithID(playId) {
                viewModel.playAtIndex = foundIndex
                self.showPlayer = true
                Task {
                    await audioPlayer.play(at: viewModel.playAtIndex)
                }
            }
        }
        .sheet(isPresented: $showPlayer) {
            makeAudioPlayerView(audioPlayer: audioPlayer)
        }
        .navigationTitle("Favorites")
    }
}
