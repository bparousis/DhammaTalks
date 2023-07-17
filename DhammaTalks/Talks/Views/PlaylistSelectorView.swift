//
//  PlaylistListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import SwiftUI
import CoreData
import Combine

struct PlaylistSelectorView: View {

    @ObservedObject private var viewModel: PlaylistSelectorViewModel
    @State private var showCreatePlaylistSheet = false
    @State private var presentDeleteAlert = false
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var deleteOffsets: IndexSet?

    init(viewModel: PlaylistSelectorViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var playlistSelectorView: some View {
        ScrollViewReader { _ in
            if viewModel.playlists.isEmpty {
                Text("No Playlists")
            } else {
                List {
                    ForEach(viewModel.playlists) { playlist in
                        NavigationLink {
                            createPlaylistView(playlist: playlist)
                        } label: {
                            PlaylistRow(playlist: playlist)
                        }
                    }
                    .onDelete(perform: deletePlaylist)
                }
                .alert("Delete Playlist?", isPresented: $presentDeleteAlert, actions: {
                    Button("Delete", action: {
                        if let deleteOffsets = deleteOffsets {
                            viewModel.deletePlaylists(at: deleteOffsets)
                        }
                    })
                    Button("Cancel", role: .cancel, action: {
                        deleteOffsets = nil
                    })
                }, message: {
                    EmptyView()
                })
            }
        }
        .sheet(isPresented: $showCreatePlaylistSheet, content: {
            NavigationView {
                Form {
                    Section("New Playlist") {
                        TextField("Title", text: $title)
                        TextField("Description", text: $desc)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Create", action: {
                            viewModel.createPlaylist(title: title, description: desc)
                            Task {
                                await viewModel.fetchPlaylists()
                            }
                            showCreatePlaylistSheet = false
                        })
                        .disabled(title.isEmpty)
                        Button("Cancel", action: {
                            showCreatePlaylistSheet = false
                        })
                    }
                }
            }
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    title = ""
                    desc = ""
                    showCreatePlaylistSheet = true
                } label: {
                    VStack {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    var body: some View {
        playlistSelectorView
            .navigationTitle("Playlists")
            .task {
                await viewModel.fetchPlaylists()
            }
    }
    
    private func deletePlaylist(at offsets: IndexSet) {
        deleteOffsets = offsets
        presentDeleteAlert = true
    }
    
    @ViewBuilder
    private func createPlaylistView(playlist: Playlist) -> some View {
        let items = playlist.playlistItems
            .convertToTalkRowViewModelArray(
                talkUserInfoService: viewModel.talkUserInfoService,
                downloadManager: viewModel.downloadManager,
                playlistService: viewModel.playlistService)
        let playlistViewModel = PlaylistViewModel(title: playlist.title,
                                          playlistItems: items,
                                          talkUserInfoService: viewModel.talkUserInfoService,
                                          downloadManager: viewModel.downloadManager)
        PlaylistView(viewModel: playlistViewModel)
    }
}

