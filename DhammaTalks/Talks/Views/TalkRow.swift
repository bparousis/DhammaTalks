//
//  TalkRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

struct TalkRow: View {

    private let talk: TalkData
    @State private var showingPlayer = false

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter
    }()
    
    init(talk: TalkData) {
        self.talk = talk
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(talk.title)").font(.headline)
                if let date = talk.date {
                    Text("\(self.dateFormatter.string(from: date))").font(.subheadline)
                }
            }
            Spacer()
            Image(systemName: "play")
        }.padding(5)
         .onTapGesture {
            self.showingPlayer = true
        }.sheet(isPresented: $showingPlayer) {
            if let talkURL = URL(string: self.talk.url) {
                MediaPlayer(url: talkURL, title: self.talk.title)
            }
        }
    }
}

