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

    @EnvironmentObject private var audioPlayer: AudioPlayer
    
    @StateObject private var viewModel: FavoritesListViewModel

    @State var searchText: String = ""
    @State var playIdentifier: TalkIdentifier? = nil
    
    init(talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager, playlistService: PlaylistService)
    {
        _viewModel = StateObject(wrappedValue: FavoritesListViewModel(talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService))
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
                            guard let foundIdentifier = viewModel.playableItemWithID(tapped.id) else {
                                return
                            }
                            playIdentifier = foundIdentifier
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            Task {
                                if let talkIdentifier = viewModel.random() {
                                    proxy.scrollTo(talkIdentifier.id)
                                    playIdentifier = talkIdentifier
                                }
                            }
                        } label: {
                            Image(systemName: "shuffle")
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
            audioPlayer.playableList = viewModel
        }
        .task(id: searchText) {
            await viewModel.fetchFavorites(searchText: searchText)
        }
        .onReceive(audioPlayer.$isActive) { isActive in
            if !isActive {
                self.playIdentifier = nil
            }
        }
        .sheet(item: $playIdentifier) { playIdentifier in
            AudioPlayerView(audioPlayer: audioPlayer, playIndex: playIdentifier.index)
                .onDisappear {
                    audioPlayer.finishPlaying()
                    self.playIdentifier = nil
                }
        }
        .navigationTitle("Favorites")
    }
}
