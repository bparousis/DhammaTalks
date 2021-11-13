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
    private let htmlPageFetcher: HTMLPageFetcher
    private let talkDataExtractor: TalkDataExtractor
    
    init(htmlPageFetcher: HTMLPageFetcher = HTMLPageFetcher(), talkDataExtractor: TalkDataExtractor = TalkDataExtractor()) {
        self.talkDataExtractor = talkDataExtractor
        self.htmlPageFetcher = htmlPageFetcher
    }
    
    func fetchEveningTalksForYear(_ year: Int) async -> [TalkSection] {

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        let eveningCategory: TalkCategory = .evening(year: year)
        let result = await htmlPageFetcher.getHTMLForCategory(eveningCategory)
        switch result {
        case .success(let html):
            var talkSectionList: [TalkSection] = []
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
                    currentTalkSection = TalkSection(title: title)
                    currentTalkSection?.addTalk(talkData)
                }
            }
            
            if let talkSection = currentTalkSection, !talkSection.talks.isEmpty {
                talkSectionList.append(talkSection)
            }
            return talkSectionList
        case .failure:
            return []
        }
    }
}
