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
    @State private var selectedCategory: YearlyTalkCategory = .evening
    @State private var talkSections: [TalkSection] = []
    @State private var showingAlert = false
    private let talkDataService = TalkDataService()
    private var years: [Int] {
        Array(selectedCategory.startYear...Self.currentYear).reversed()
    }
    
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
        .toolbar {
            Picker("Select a category", selection: $selectedCategory) {
                ForEach(YearlyTalkCategory.allCases, id: \.self) {
                    Text($0.title)
                }
            }
            .pickerStyle(.segmented)
        }
        .alert("Failed to load talks", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .task(id: selectedCategory) {
            await fetchData()
        }
        .task(id: selectedYear) {
            await fetchData()
        }
        .listStyle(.insetGrouped)
        .navigationBarTitle("Dhamma Talks", displayMode: .inline)
    }
    
    private func fetchData() async {
        if selectedYear < selectedCategory.startYear {
            selectedYear = selectedCategory.startYear
        }
        
        let result = await talkDataService.fetchYearlyTalks(category: selectedCategory, year: selectedYear)
        switch result {
        case .success(let talkSections):
            self.talkSections = talkSections
        case .failure:
            showingAlert = true
        }
    }
}

struct YearlyTalkListView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            YearlyTalkListView()
        }
    }
}
