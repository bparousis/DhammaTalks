//
//  Array.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-02.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

extension Array where Element == TalkData {
    func splitIntoSections() -> [TalkSection] {
        var talkSectionList: [TalkSection] = []
        var currentTalkSection: TalkSection?
        for talkData in self {
            guard let date = talkData.date else {
                continue
            }

            let sectionTitle = DateFormatter.talkSectionDateFormatter.string(from: date)
            if currentTalkSection?.title == sectionTitle {
                currentTalkSection?.addTalk(talkData)
            } else {
                if let talkSection = currentTalkSection {
                    talkSectionList.append(talkSection)
                }
                currentTalkSection = TalkSection(id: UUID().uuidString, title: sectionTitle)
                currentTalkSection?.addTalk(talkData)
            }
        }
        
        if let talkSection = currentTalkSection, !talkSection.talks.isEmpty {
            talkSectionList.append(talkSection)
        }
        return talkSectionList
    }
}
