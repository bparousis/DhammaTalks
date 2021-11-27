//
//  TalkRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import AVKit

struct TalkRow: View {

    private let talk: TalkData
    @State private var playerItem: AVPlayerItem?

    @State var currentTime: CMTime = CMTime()
    @State var totalTime: CMTime = CMTime()

    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter
    }()
    
    private var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.includesTimeRemainingPhrase = true
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
    
    init(talk: TalkData) {
        self.talk = talk
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text(talk.title)
                    .font(.headline)
                if let date = talk.date {
                    Text(self.dateFormatter.string(from: date))
                        .font(.subheadline)
                }
                if currentTimeInSeconds > 0 && totalTimeInSeconds > 0 {
                    if currentTime >= totalTime {
                       Text("Played")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    } else {
                        Spacer()
                        HStack(spacing: 10) {
                            ProgressView(value: currentTimeInSeconds, total: totalTimeInSeconds)
                                .frame(width: 75)
                            if let timeString = dateComponentsFormatter.string(from: TimeInterval(totalTimeInSeconds - currentTimeInSeconds)) {
                                Text(timeString)
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
            }
            Spacer()
            Image(systemName: "play")
        }
        .padding(5)
        .onTapGesture {
            if let url = talk.makeURL() {
                self.playerItem = AVPlayerItem(url: url)
                if currentTimeInSeconds > 0 {
                    playerItem?.seek(to: currentTime, completionHandler: nil)
                }
            }
        }
        .sheet(item: $playerItem) { item in
            MediaPlayer(playerItem: item, title: talk.title)
            .onDisappear{
                currentTime = item.currentTime()
                totalTime = item.duration
            }
        }
    }
    
    var currentTimeInSeconds: Float {
        Float(currentTime.value)/Float(currentTime.timescale)
    }
    
    var totalTimeInSeconds: Float {
        Float(totalTime.value)/Float(totalTime.timescale)
    }
}

extension AVPlayerItem: Identifiable {
    public var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}
