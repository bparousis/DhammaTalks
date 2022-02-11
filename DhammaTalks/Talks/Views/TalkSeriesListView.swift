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
    
    init(viewModel: TalkSeriesListViewModel) {
        self.viewModel = viewModel
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
                        TalkRow(viewModel: talkRowViewModel)
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
        .navigationBarTitle(viewModel.title, displayMode: .inline)
    }
}
