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

    private let talkDataList: [TalkData]
    private let title: String
    
    init(title: String, talkDataList: [TalkData]) {
        self.title = title
        self.talkDataList = talkDataList
    }
    
    var body: some View {
        List {
            Section(header: TalkSectionHeader(title: "", talkCount: talkDataList.count)) {
                ForEach(talkDataList) { talk in
                    TalkRow(talk: talk)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle(title, displayMode: .inline)
    }
}

struct TalkSeriesListView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            TalkSeriesListView(title: "", talkDataList: [])
        }
    }
}
