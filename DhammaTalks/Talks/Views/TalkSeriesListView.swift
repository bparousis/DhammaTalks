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
    
    init(talkSeries: TalkSeries) {
        self.talkSeries = talkSeries
    }
    
    var body: some View {
        List {
            ForEach(talkSeries.sections) { section in
                Section(header: TalkSectionHeader(title: section.title ?? "", talkCount: section.talks.count)) {
                    ForEach(section.talks) { talk in
                        TalkRow(talk: talk)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle(talkSeries.title, displayMode: .inline)
    }
}

struct TalkSeriesListView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            TalkSeriesListView(talkSeries: TalkSeries(title: "", description: "", image: "", sections: []))
        }
    }
}
