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
    
    init(viewModel: DailyTalkListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            if !viewModel.isFetchDataFinished {
                Section {
                    ProgressView()
                }
            } else {
                Section {
                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(viewModel.years, id: \.self) {
                            Text(String($0))
                        }
                    }
                }

                ForEach(viewModel.talkSections) { talkSection in
                    Section(header: TalkSectionHeader(title: talkSection.title ?? "", talkCount: talkSection.talks.count)) {
                        ForEach(talkSection.talks) { talk in
                            TalkRow(talk: talk)
                        }
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
        .task(id: viewModel.selectedCategory) {
            await viewModel.fetchData()
        }
        .task(id: viewModel.selectedYear) {
            await viewModel.fetchData()
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Daily Talks", displayMode: .inline)
    }
}

struct YearlyTalkListView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            DailyTalkListView(viewModel: DailyTalkListViewModel(talkDataService: TalkDataService()))
        }
    }
}
