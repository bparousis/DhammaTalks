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
    @State private var showSortSheet = false

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
                            PlaylistRow(viewModel: PlaylistRowViewModel(playlist: playlist))
                        }
                    }
                    .onDelete(perform: deletePlaylist)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            Task {
                                showSortSheet = true
                            }
                        } label: {
                            VStack {
                                Image(systemName: "arrow.up.arrow.down.circle")
                                Text("Sort")
                            }
                        }
                        .confirmationDialog(Text("Sort By"), isPresented: $showSortSheet) {
                            ForEach(viewModel.sortList) { sort in
                                Button(sort.title) {
                                    viewModel.selectedSort = sort
                                    Task {
                                        await viewModel.fetchPlaylists()
                                    }
                                }
                            }
                        }
                    }
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
        .navigationTitle("Playlists")
        .task {
            await viewModel.fetchPlaylists()
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
    }
    
    private func deletePlaylist(at offsets: IndexSet) {
        deleteOffsets = offsets
        presentDeleteAlert = true
    }
    
    @ViewBuilder
    private func createPlaylistView(playlist: Playlist) -> some View {
        let playlistViewModel = PlaylistViewModel(playlist: playlist,
                                                  talkUserInfoService: viewModel.talkUserInfoService,
                                                  downloadManager: viewModel.downloadManager,
                                                  playlistService: viewModel.playlistService)
        PlaylistView(viewModel: playlistViewModel)
    }
}

