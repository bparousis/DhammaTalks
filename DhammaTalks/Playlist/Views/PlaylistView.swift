//
//  PlaylistView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-02-25.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct PlaylistView: View {
    
    @EnvironmentObject private var audioPlayer: AudioPlayer

    @StateObject private var viewModel: PlaylistViewModel
    @State var searchText: String = ""
    @State var playIdentifier: TalkIdentifier? = nil

    init(playlist: Playlist,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService)
    {
        _viewModel = StateObject(wrappedValue: PlaylistViewModel(playlist: playlist, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService))
    }
    
    @ViewBuilder
    private var playlistView: some View {
        if viewModel.playlistItems.isEmpty && searchText.isEmpty {
            Text("Playlist is empty")
        } else {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.playlistItems) { playlistItemRow in
                        TalkRow(viewModel: playlistItemRow) { tapped in
                            guard let foundIdentifier = viewModel.playableItemWithID(tapped.id) else {
                                return
                            }
                            playIdentifier = foundIdentifier
                        }
                    }
                    .onMove { fromOffsets, toOffset in
                        viewModel.moveItem(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    .onDelete { offsets in
                        viewModel.deleteItems(fromOffsets: offsets)
                    }
                }
                .toolbar {
                    EditButton()
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
        playlistView
        .onReceive(viewModel.savePublisher) { _ in
        }
        .task {
            viewModel.searchPlaylistItems(searchText: searchText)
            audioPlayer.playableList = viewModel
        }
        .task(id: searchText) {
            viewModel.searchPlaylistItems(searchText: searchText)
        }
        .onReceive(audioPlayer.$isActive) { isActive in
            if !isActive {
                self.playIdentifier = nil
            }
        }
        .sheet(item: $playIdentifier,
               onDismiss: {
            audioPlayer.finish()
            self.playIdentifier = nil
        }) { playIdentifier in
            AudioPlayerView(audioPlayer: audioPlayer, playIndex: playIdentifier.index)
        }
        .navigationTitle(viewModel.title)
    }
}
