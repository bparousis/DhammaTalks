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
    @State private var playbackSession: PlaybackSession?

    init(viewModel: FavoritesListViewModel) {
        self.viewModel = viewModel
    }

    private func startPlayback(items: [any PlayableItem], index: Int) {
        let player = AudioPlayer(playableItems: { items })
        playbackSession = PlaybackSession(player: player)
        Task {
            await player.play(at: index)
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
                        TalkRow(viewModel: favoriteRow) { tapped in
                            guard let index = viewModel.favorites.firstIndex(where: { $0.id == tapped.id }) else { return }
                            startPlayback(items: viewModel.flatPlayableItems, index: index)
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            if let (id, index) = viewModel.playRandomTalk() {
                                startPlayback(items: viewModel.flatPlayableItems, index: index)
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
        .sheet(item: $playbackSession) { session in
            AudioPlayerView(audioPlayer: session.player)
                .onDisappear {
                    session.player.finishPlaying()
                    playbackSession = nil
                }
        }
        .navigationTitle("Favorites")
    }
}
