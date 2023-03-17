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
    @State private var presentCreateAlert = false
    @State private var presentDeleteAlert = false
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var deleteOffsets: IndexSet?

    init(viewModel: PlaylistSelectorViewModel) {
        self.viewModel = viewModel
    }
    
    @ViewBuilder
    private var playlistSelectorView: some View {
        if viewModel.playlists.isEmpty {
            Text("No Playlists")
        } else {
            ScrollViewReader { proxy in
                List {
                    ForEach(viewModel.playlists) { playlist in
                        NavigationLink {
                            createPlaylistView(playlist: playlist)
                        } label: {
                            createPlaylistRow(playlist: playlist)
                        }
                    }
                    .onDelete(perform: deletePlaylist)
                }
                .alert("Add Playlist", isPresented: $presentCreateAlert, actions: {
                    TextField("Title", text: $title)
                    TextField("Description", text: $desc)
                    Button("Create", action: {
                        viewModel.createPlaylist(title: title, description: desc)
                    })
                    Button("Cancel", role: .cancel, action: {})
                }, message: {
                    EmptyView()
                })
                .alert("Delete Playlist?", isPresented: $presentDeleteAlert, actions: {
                    Button("Delete", action: {
                        if let deleteOffsets = deleteOffsets {
                            viewModel.playlists.remove(atOffsets: deleteOffsets)
                        }
                    })
                    Button("Cancel", role: .cancel, action: {
                        deleteOffsets = nil
                    })
                }, message: {
                    EmptyView()
                })
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            presentCreateAlert = true
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                            }
                        }
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
    private func createPlaylistRow(playlist: Playlist) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.headline)
                HStack {
                    let talksCount = "\(playlist.playlistItems.count) talks"
                    if let description = playlist.desc {
                        Text("\(description) • \(talksCount)")
                    } else {
                        Text("\(talksCount)")
                    }
                }
                .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func createPlaylistView(playlist: Playlist) -> some View {
        let items = playlist.playlistItems
            .convertToTalkRowViewModelArray(
                talkUserInfoService: viewModel.talkUserInfoService,
                downloadManager: viewModel.downloadManager)
        let viewModel = PlaylistViewModel(title: playlist.title,
                                          playlistItems: items,
                                          talkUserInfoService: viewModel.talkUserInfoService,
                                          downloadManager: viewModel.downloadManager)
        PlaylistView(viewModel: viewModel)
    }
}

