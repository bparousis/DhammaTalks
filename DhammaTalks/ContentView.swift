//
//  ContentView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    let allTalks: [YearSection] = {
        let year = Calendar.current.component(.year, from: Date())
        return TalkDataService().fetchTalks(yearRange: 2018...year)
    }()
    
    let categoryTalks: [CategoryTalks]? = {
        if let path = Bundle.main.path(forResource: "CategoryTalks", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let categoryTalks = try JSONDecoder().decode([CategoryTalks].self, from: data)
                return categoryTalks
            } catch {
                return nil
            }
        }
        return nil
    }()
        
    private var player: AVAudioPlayer?
    
    var body: some View {
        return NavigationView {
            List {
                ForEach(allTalks) { yearSection in
                    Section(header: ListHeader(year: yearSection.year, talkCount: yearSection.talks.count)) {
                        ForEach(yearSection.talks) { talk in
                            TalkRow(talk: talk)
                        }
                    }
                }
            }.navigationBarTitle("Evening Dhamma Talks", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ListHeader: View {
    let year: String
    let talkCount: Int

    var body: some View {
        HStack {
            Text(year)
            Spacer()
            Text("talk-count \(talkCount)")
        }
    }
}
