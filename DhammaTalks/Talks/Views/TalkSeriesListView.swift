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

    @EnvironmentObject private var audioPlayer: AudioPlayer

    @StateObject private var viewModel: TalkSeriesListViewModel
    @State private var searchText: String = ""
    @State private var playIdentifier: TalkIdentifier? = nil
    
    init(talkSeries: TalkSeries, talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager, playlistService: PlaylistService)
    {
        _viewModel = StateObject(wrappedValue: TalkSeriesListViewModel(talkSeries: talkSeries, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService))
    }
    
    var body: some View {
        List {
            Section {
                // .init is a workaround so that markdown in text works.
                Text(.init(viewModel.description))
            }
            ForEach(viewModel.talkSections) { section in
                Section(header: TalkSectionHeader(title: section.title, talkCount: section.talkRows.count)) {
                    ForEach(section.talkRows) { talkRowViewModel in
                        TalkRow(viewModel: talkRowViewModel) { tapped in
                            guard let foundIdentifier = viewModel.playableItemWithID(tapped.id) else {
                                return
                            }
                            playIdentifier = foundIdentifier
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .task {
            viewModel.fetchData()
            audioPlayer.playableList = viewModel
        }
        .task(id: searchText) {
            viewModel.fetchData(searchText: searchText)
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
        .listStyle(.insetGrouped)
        .navigationBarTitle(viewModel.title, displayMode: .inline)
    }
}
