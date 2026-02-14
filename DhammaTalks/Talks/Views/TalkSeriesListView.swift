//
//  TalkSeriesListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-16.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI

struct TalkSeriesListView: View {

    @ObservedObject private var viewModel: TalkSeriesListViewModel
    @State private var searchText: String = ""
    @State private var playbackSession: PlaybackSession?

    init(viewModel: TalkSeriesListViewModel) {
        self.viewModel = viewModel
    }

    private func startPlayback(items: [any PlayableItem], index: Int) {
        let player = AudioPlayer(playableItems: { items })
        playbackSession = PlaybackSession(player: player)
        Task {
            await player.play(at: index)
        }
    }

    var body: some View {
        List {
            Section {
                // .init is a workaround so that markdown in text works.
                Text(.init(viewModel.description))
            }
            ForEach(viewModel.talkSections) { section in
                let flatItems = viewModel.flatPlayableItems
                Section(header: TalkSectionHeader(title: section.title, talkCount: section.talkRows.count)) {
                    ForEach(section.talkRows) { talkRowViewModel in
                        TalkRow(viewModel: talkRowViewModel) { tapped in
                            guard let index = flatItems.firstIndex(where: { $0.id == tapped.id }) else { return }
                            startPlayback(items: flatItems, index: index)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .task {
            viewModel.fetchData()
        }
        .task(id: searchText) {
            viewModel.fetchData(searchText: searchText)
        }
        .listStyle(.insetGrouped)
        .sheet(item: $playbackSession) { session in
            AudioPlayerView(audioPlayer: session.player)
                .onDisappear {
                    session.player.finishPlaying()
                    playbackSession = nil
                }
        }
        .navigationBarTitle(viewModel.title, displayMode: .inline)
    }
}
