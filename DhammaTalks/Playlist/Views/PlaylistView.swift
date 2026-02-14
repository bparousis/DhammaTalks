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
    @State private var playbackSession: PlaybackSession?

    init(viewModel: PlaylistViewModel) {
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
    private var playlistView: some View {
        if viewModel.playlistItems.isEmpty && searchText.isEmpty {
            Text("Playlist is empty")
        } else {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.playlistItems) { playlistItemRow in
                        TalkRow(viewModel: playlistItemRow) { tapped in
                            guard let index = viewModel.playlistItems.firstIndex(where: { $0.id == tapped.id }) else { return }
                            startPlayback(items: viewModel.flatPlayableItems, index: index)
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
        playlistView
        .onReceive(viewModel.savePublisher) { _ in
        }
        .task {
            viewModel.searchPlaylistItems(searchText: searchText)
        }
        .task(id: searchText) {
            viewModel.searchPlaylistItems(searchText: searchText)
        }
        .sheet(item: $playbackSession) { session in
            AudioPlayerView(audioPlayer: session.player)
                .onDisappear {
                    session.player.finishPlaying()
                    playbackSession = nil
                }
        }
        .navigationTitle(viewModel.title)
    }
}
