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
    
    private lazy var monthFormatter: DateFormatter = {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        return monthFormatter
    }()
    
    init(htmlPageFetcher: HTMLPageFetcher = HTMLPageFetcher(), talkDataExtractor: TalkDataExtractor = TalkDataExtractor()) {
        self.talkDataExtractor = talkDataExtractor
        self.htmlPageFetcher = htmlPageFetcher
    }
    
    func fetchYearlyTalks(category: YearlyTalkCategory, year: Int) async -> Result<[TalkSection], Error> {

        let fetchResult = await htmlPageFetcher.getYearlyHTMLForCategory(category, year: year)
        switch fetchResult {
        case .success(let html):
            return getTalkSectionsFromHTML(html)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getTalkSectionsFromHTML(_ htmlData: YearlyHTMLData) -> Result<[TalkSection], Error> {
        
        let result = talkDataExtractor.extractTalkDataFromHTML(htmlData)
        switch result {
        case .success(let talkDataList):
            var talkSectionList: [TalkSection] = []
            var currentTalkSection: TalkSection?
            for talkData in talkDataList {
                guard let date = talkData.date else {
                    continue
                }
                let month = monthFormatter.string(from: date)
                let title = "\(month) \(htmlData.year)"
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
            return .success(talkSectionList)
        case .failure(let error):
            return .failure(error)
        }
    }
}
