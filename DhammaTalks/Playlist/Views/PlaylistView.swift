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

    @ObservedObject private var viewModel: PlaylistViewModel
    @State var searchText: String = ""
    @State var showPlayer: Bool = false
    private let audioPlayer: AudioPlayer

    init(viewModel: PlaylistViewModel) {
        self.viewModel = viewModel
        self.audioPlayer = AudioPlayer {
            viewModel.playableItems
        }
    }
    
    @ViewBuilder
    private var playlistView: some View {
        if viewModel.playlistItems.isEmpty && searchText.isEmpty {
            Text("Playlist is empty")
        } else {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.playlistItems) { playlistItemRow in
                        TalkRow(viewModel: playlistItemRow)
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
        playlistView
        .onReceive(viewModel.playPublisher) { playId in
            if let foundIndex = viewModel.findIndexOfPlayableItemWithID(playId) {
                viewModel.playAtIndex = foundIndex
                self.showPlayer = true
                Task {
                    await audioPlayer.play(at: viewModel.playAtIndex)
                }
            }
        }
        .task {
            viewModel.searchPlaylistItems(searchText: searchText)
        }
        .task(id: searchText) {
            viewModel.searchPlaylistItems(searchText: searchText)
        }
        .sheet(isPresented: $showPlayer) {
            makeAudioPlayerView(audioPlayer: audioPlayer)
        }
        .navigationTitle(viewModel.title)
    }
}
