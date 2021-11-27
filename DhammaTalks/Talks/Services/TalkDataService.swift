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

    private let htmlPageFetcher: HTMLPageFetcher
    
    private lazy var monthFormatter: DateFormatter = {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        return monthFormatter
    }()
    
    static let talkSeriesList: [TalkSeries]? = {
        if let path = Bundle.main.path(forResource: "TalkSeriesList", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let talkSeriesList = try JSONDecoder().decode([TalkSeries].self, from: data)
                return talkSeriesList
            } catch {
                return nil
            }
        }
        return nil
    }()
    
    init(htmlPageFetcher: HTMLPageFetcher = HTMLPageFetcher()) {
        self.htmlPageFetcher = htmlPageFetcher
    }
    
    func fetchYearlyTalks(category: DailyTalkCategory, year: Int) async -> Result<[TalkSection], Error> {

        let fetchResult = await htmlPageFetcher.getYearlyHTMLForCategory(category, year: year)
        switch fetchResult {
        case .success(let html):
            return getTalkSectionsFromHTML(html)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func getTalkSectionsFromHTML(_ htmlData: YearlyHTMLData) -> Result<[TalkSection], Error> {
        
        let result = htmlData.parseTalkData()
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
                    currentTalkSection = TalkSection(id: UUID().uuidString, title: title)
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
