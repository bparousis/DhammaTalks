//
//  TalkDataService.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup

class TalkDataService {

    private let parser = AudioFileNameParser()
    static let dhammaTalksArchiveAddress = "https://www.dhammatalks.org/Archive"
    private let talkDataExtractor: TalkDataExtractor
    
    init(talkDataExtractor: TalkDataExtractor = TalkDataExtractor()) {
        self.talkDataExtractor = talkDataExtractor
    }
    
    func fetchTalksForYear(_ year: Int) -> [TalkSection] {
        var talkSectionList: [TalkSection] = []
        guard let pageUrl = URL(string: "\(TalkDataService.dhammaTalksArchiveAddress)/y\(year)/") else {
            return []
        }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        var talkSectionId = 0
        if let html = try? String(contentsOf: pageUrl) {
            let talkDataList = talkDataExtractor.extractFromHTML(html)
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
                    currentTalkSection = TalkSection(id: talkSectionId, title: title)
                    currentTalkSection?.addTalk(talkData)
                    talkSectionId += 1
                }
            }
            
            if let talkSection = currentTalkSection, !talkSection.talks.isEmpty {
                talkSectionList.append(talkSection)
            }
        }
        return talkSectionList
    }
}
