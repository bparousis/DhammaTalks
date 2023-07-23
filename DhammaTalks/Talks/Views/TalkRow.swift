//
//  TalkRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

struct TalkRow: View {
    @ObservedObject var viewModel: TalkRowViewModel

    @State private var showActionSheet = false
    @State private var selectedPlaylist: Playlist? = nil
    @State private var showCreatePlaylistSheet = false
    @State private var title: String = ""
    @State private var desc: String = ""
    @State private var addedToPlaylist = false

    @ViewBuilder
    private var actionButton: some View {
        let buttonSize: CGFloat = 25
        if viewModel.downloadProgress != nil {
            CircularProgressBar(progress: $viewModel.downloadProgress, lineWidth: 2.0) {
                viewModel.cancelDownload()
            }
            .frame(width: buttonSize, height: buttonSize, alignment: .center)
        } else {
            Button(action: { showActionSheet = true }) {
                Image(systemName: "ellipsis")
                    .frame(width: buttonSize, height: buttonSize, alignment: .center)
            }
        }
    }
    
    @ViewBuilder
    private var playedStateView: some View {
        switch viewModel.state {
        case .played:
            Text("Played")
                 .foregroundColor(.secondary)
                 .font(.system(size: 12))
        case .inProgress:
            HStack {
                if let currentTimeInSeconds = viewModel.currentTimeString {
                    Text(currentTimeInSeconds)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
                ProgressView(value: viewModel.currentTimeInSeconds, total: viewModel.totalTimeInSeconds)
                if let timeRemaining = viewModel.timeRemainingString {
                    Text(timeRemaining)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
        case .unplayed:
            EmptyView()
        }
    }

    @ViewBuilder
    private func makeMediaPlayerView(item: AVPlayerItem) -> some View {
        if isIpad {
            MediaPlayer(playerItem: item, title: viewModel.title)
        } else {
            VStack {
                swipeBar
                MediaPlayer(playerItem: item, title: viewModel.title)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var titleStatusView: some View {
        HStack(alignment: .firstTextBaseline) {
            if viewModel.dateStyle == .day, let formattedDay = viewModel.formattedDay, !formattedDay.isEmpty {
                Text(formattedDay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(viewModel.title)
                .font(.headline)
            talkIcons
        }
    }
    
    private var talkIcons: some View {
        HStack(spacing: 2) {
            let iconSize: CGFloat = 11.5
            if viewModel.favorite {
                Image(systemName: "star.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(Color(.systemYellow))
            }
            if viewModel.isDownloadAvailable {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: iconSize))
                    .foregroundColor(Color(.systemBlue))
            }
            if !viewModel.notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.system(size: iconSize))
                    .foregroundColor(Color(.systemGray))
            }
        }
    }
    
    @ViewBuilder
    private var fullDateView: some View {
        if let formattedDate = viewModel.formattedDate {
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var playlistSelectorView: some View {
        NavigationView {
            if !addedToPlaylist {
                List {
                    ForEach(viewModel.playlists, id: \.self) { playlist in
                        Button {
                            viewModel.addToPlaylist(playlist)
                            addedToPlaylist = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.viewModel.showPlaylistSelector = false
                                addedToPlaylist = false
                            }
                        } label: {
                            PlaylistRow(viewModel: PlaylistRowViewModel(playlist: playlist))
                        }
                        .foregroundColor(.primary)
                        .padding(5)
                    }
                }
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
                        Button("Cancel") {
                            viewModel.showPlaylistSelector = false
                        }
                    }
                }
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
                .navigationTitle("Playlists")
            } else {
                VStack(spacing: 10) {
                    Text("Successfully added to playlist")
                        .font(.headline)
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 100))
                }
            }
        }
    }

    var body: some View {
        Button(action: {
            Task {
                await viewModel.play()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    titleStatusView
                    if viewModel.dateStyle == .full {
                        fullDateView
                    }
                    playedStateView
                }
                Spacer()
                actionButton
            }
        }
        .confirmationDialog(Text(viewModel.title), isPresented: $showActionSheet) {
            ForEach(viewModel.actions) { action in
                Button(action.title) {
                    viewModel.handleAction(action)
                }
            }
        }
        .foregroundColor(.primary)
        .padding(5)
        .sheet(isPresented: $viewModel.showNotes) {
            NavigationView {
                TextEditor(text: $viewModel.notes)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Notes")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button("Done") {
                                viewModel.saveNotes()
                                viewModel.showNotes = false
                            }
                        }
                    }
            }
            .interactiveDismissDisabled()
        }
        .sheet(item: $viewModel.playerItem) { item in
            makeMediaPlayerView(item: item)
            .onDisappear {
                viewModel.finishedPlaying(item: item)
            }
        }
        .sheet(isPresented: $viewModel.showPlaylistSelector) {
            playlistSelectorView
        }
        .onAppear {
            viewModel.fetchTalkInfo()
        }
    }
}
