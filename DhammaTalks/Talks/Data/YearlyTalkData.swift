//
//  YearlyTalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup

struct YearlyTalkData {
    let talkDataList: [TalkData]
    let talkCategory: DailyTalkCategory
    let year: Int
    private let monthFormatter = DateFormatter()

    func getTalkSections() -> [TalkSection] {
        monthFormatter.dateFormat = "LLLL"
        var talkSectionList: [TalkSection] = []
        var currentTalkSection: TalkSection?
        for talkData in talkDataList {
            guard let date = talkData.date else {
                continue
            }
            let month = monthFormatter.string(from: date)
            let title = "\(month) \(year)"
            if currentTalkSection?.title == title {
                currentTalkSection?.addTalk(talkData)
            } else {
                if let talkSection = currentTalkSection {
                    talkSectionList.append(talkSection)
                }
                currentTalkSection = TalkSection(id: UUID().uuidString, title: title)
                currentTalkSection?.addTalk(talkData)
            }
        }
        
        if let talkSection = currentTalkSection, !talkSection.talks.isEmpty {
            talkSectionList.append(talkSection)
        }
        return talkSectionList
    }
}
