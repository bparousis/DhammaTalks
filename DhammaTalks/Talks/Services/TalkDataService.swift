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
        case .success(let yearlyTalkData):
            return .success(yearlyTalkData.getTalkSections())
        case .failure(let error):
            return .failure(error)
        }
    }
}
