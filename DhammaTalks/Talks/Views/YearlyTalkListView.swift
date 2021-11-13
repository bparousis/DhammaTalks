//
//  YearlyTalkListView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI

private struct TalkSectionHeader: View {
    let title: String
    let talkCount: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("talk-count \(talkCount)")
        }
    }
}

struct YearlyTalkListView: View {

    private static var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    @State private var selectedYear = Self.currentYear
    @State private var talkSections: [TalkSection] = []
    private let talkDataService = TalkDataService()
    private let years: [Int] = Array(2000...Self.currentYear).reversed()
    
    var body: some View {
        List {
            Section {
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) {
                        Text(String($0))
                    }
                }
            }

            ForEach(talkSections) { talkSection in
                Section(header: TalkSectionHeader(title: talkSection.title, talkCount: talkSection.talks.count)) {
                    ForEach(talkSection.talks) { talk in
                        TalkRow(talk: talk)
                    }
                }
            }
        }
        .task(id: selectedYear) {
            talkSections = await talkDataService.fetchEveningTalksForYear(selectedYear)
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Evening Dhamma Talks", displayMode: .inline)
    }
}

struct YearlyTalkListView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            YearlyTalkListView()
        }
    }
}
