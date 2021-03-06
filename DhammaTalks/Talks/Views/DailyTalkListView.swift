//
//  DailyTalkListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

struct DailyTalkListView: View {
    
    @ObservedObject private var viewModel: DailyTalkListViewModel
    
    @State private var searchText = ""

    init(viewModel: DailyTalkListViewModel) {
        self.viewModel = viewModel
    }
    
    private var datePickerView: some View {
        Section {
            Picker("Year", selection: $viewModel.selectedYear) {
                ForEach(viewModel.years, id: \.self) {
                    Text(String($0))
                }
            }
        }
    }
    
    private func createTalkSectionsView(_ talkSections: [TalkSectionViewModel]) -> some View {
        ForEach(talkSections) { talkSection in
            Section(header: TalkSectionHeader(title: talkSection.title, talkCount: talkSection.talkRows.count)) {
                ForEach(talkSection.talkRows) { talkRow in
                    TalkRow(viewModel: talkRow)
                }
            }
        }
    }
    
    private var listView: some View {
        List {
            switch viewModel.state {
            // For error showingAlert will be true, which will cause an alert to be shown.
            case .initial, .error:
                EmptyView()
            case .loading:
                Section {
                    ProgressView()
                }
            case .loaded(let sections):
                datePickerView
                createTalkSectionsView(sections)
            }
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
            .toolbar {
                Picker("Select a category", selection: $viewModel.selectedCategory) {
                    ForEach(DailyTalkCategory.allCases, id: \.self) {
                        Text($0.title)
                    }
                }
                .pickerStyle(.segmented)
            }
            .alert("Failed to load talks", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .task(id: DailyTalkQuery(category: viewModel.selectedCategory, year: viewModel.selectedYear, searchText:searchText)) {
                await viewModel.fetchData(searchText: searchText)
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarTitle("Daily Talks", displayMode: .inline)
    }
}
