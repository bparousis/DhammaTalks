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

    init(viewModel: PlaylistViewModel) {
        self.viewModel = viewModel
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
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            Task {
                                if let id = await viewModel.playRandomTalk() {
                                    proxy.scrollTo(id)
                                }
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
        .navigationTitle(viewModel.title)
    }
}
