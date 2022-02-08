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

    private let talkSeries: TalkSeries
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    
    init(talkSeries: TalkSeries, talkUserInfoService: TalkUserInfoService, downloadManager: DownloadManager) {
        self.talkSeries = talkSeries
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }
    
    var body: some View {
        List {
            Section {
                // .init is a workaround so that markdown in text works.
                Text(.init(talkSeries.description))
            }
            ForEach(talkSeries.sections) { section in
                Section(header: TalkSectionHeader(title: section.title ?? "", talkCount: section.talks.count)) {
                    ForEach(section.talks) { talk in
                        let viewModel = TalkRowViewModel(talkData: talk, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
                        TalkRow(viewModel: viewModel)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle(talkSeries.title, displayMode: .inline)
    }
}
