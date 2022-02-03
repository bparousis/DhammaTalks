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
    @EnvironmentObject private var downloadManager: DownloadManager
    
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
    
    private var talkSectionsView: some View {
        ForEach(viewModel.talkSections) { talkSection in
            Section(header: TalkSectionHeader(title: talkSection.title ?? "", talkCount: talkSection.talks.count)) {
                ForEach(talkSection.talks) { talk in
                    let viewModel = TalkRowViewModel(talkData: talk, talkUserInfoService: viewModel.talkUserInfoService, downloadManager: downloadManager)
                    TalkRow(viewModel: viewModel)
                }
            }
        }
    }

    var body: some View {
        List {
            if !viewModel.isFetchDataFinished {
                Section {
                    ProgressView()
                }
            } else {
                datePickerView
                talkSectionsView
            }
        }
        .searchable(text: $searchText)
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
        .task(id: searchText) {
            await viewModel.fetchData(searchText: searchText)
        }
        .task(id: viewModel.selectedCategory) {
            await viewModel.fetchData(searchText: searchText)
        }
        .task(id: viewModel.selectedYear) {
            await viewModel.fetchData(searchText: searchText)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Daily Talks", displayMode: .inline)
    }
}
