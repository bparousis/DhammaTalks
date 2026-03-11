//
//  DailyTalkListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

struct DailyTalkListView: View {

    @EnvironmentObject private var audioPlayer: AudioPlayer

    @StateObject private var viewModel: DailyTalkListViewModel

    @State private var searchText = ""
    @State private var showFilterSheet = false
    @State private var playIdentifier: TalkIdentifier? = nil
    
    private var datePickerView: some View {
        Section {
            Picker("Year", selection: $viewModel.selectedYear) {
                ForEach(viewModel.years, id: \.self) {
                    Text(String($0))
                }
            }
        }
    }
    
    private var filterButton: some View {
        Button {
            if viewModel.selectedFilter == .empty {
                showFilterSheet = true
            } else {
                viewModel.selectedFilter = .empty
            }
        } label: {
            VStack {
                Image(systemName: viewModel.filterImageName)
            }
        }
        .confirmationDialog(Text("Filter"), isPresented: $showFilterSheet) {
            ForEach(viewModel.filters) { filter in
                Button(filter.title) {
                    viewModel.selectedFilter = filter
                }
            }
        }
    }
    
    private func randomPlayButton(proxy: ScrollViewProxy) -> some View {
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
    
    init(talkDataService: TalkDataService,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService)
    {
        _viewModel = StateObject(
            wrappedValue: DailyTalkListViewModel(talkDataService: talkDataService, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager, playlistService: playlistService)
        )
    }
    
    @ViewBuilder
    private func createTalkSectionsView(_ talkSections: [TalkSectionViewModel]) -> some View {
        if talkSections.isEmpty {
            Text(viewModel.selectedFilter.emptyListText)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            List {
                datePickerView
                ForEach(talkSections) { talkSection in
                    Section(header: TalkSectionHeader(title: talkSection.title,
                                                      talkCount: talkSection.talkRows.count)) {
                        ForEach(talkSection.talkRows) { talkRow in
                            TalkRow(viewModel: talkRow) { tapped in
                                guard let foundIdentifier = viewModel.playableItemWithID(tapped.id) else {
                                    return
                                }
                                playIdentifier = foundIdentifier
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        switch viewModel.state {
        // For error showingAlert will be true, which will cause an alert to be shown.
        case .initial, .error:
            EmptyView()
        case .loading:
            Section {
                ProgressView()
            }
        case .loaded(let sections):
            createTalkSectionsView(sections)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            listView
            .searchable(text: $searchText)
            .refreshable {
                if viewModel.isRefreshable {
                    await viewModel.fetchData()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    randomPlayButton(proxy: proxy)
                    Spacer()
                    filterButton
                    Spacer()
                }
            }
            .toolbar {
                Picker("Select a category", selection: $viewModel.selectedCategory) {
                    ForEach(DailyTalkCategory.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(.menu)
            }
            .alert("Failed to load talks", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Update Needed", isPresented: $viewModel.showingMinimumVersionAlert, actions: {
                Link("Update", destination: URL(string: "itms-apps://itunes.apple.com/app/id1602298092")!)
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Please update your application to a newer version as we stopped supporting this version.  We're sorry for any inconvenience.")
            })
            .onReceive(audioPlayer.$isActive) { isActive in
                if !isActive {
                    self.playIdentifier = nil
                }
            }
            .sheet(item: $playIdentifier,
                   onDismiss: {
                audioPlayer.finishPlaying()
                self.playIdentifier = nil
            }) { playIdentifier in
                AudioPlayerView(audioPlayer: audioPlayer, playIndex: playIdentifier.index)
            }
            .task(id: DailyTalkQuery(category: viewModel.selectedCategory,
                                     year: viewModel.selectedYear,
                                     searchText:searchText)) {
                audioPlayer.playableList = viewModel
                await viewModel.fetchData(searchText: searchText)
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarTitle("Daily Talks", displayMode: .inline)
    }
}
