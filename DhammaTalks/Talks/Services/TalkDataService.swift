//
//  TalkDataService.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup

struct DailyTalkQuery {
    let category: DailyTalkCategory
    let year: Int
    var searchText: String?
}

class TalkDataService: ObservableObject {

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
    
    func fetchYearlyTalks(query: DailyTalkQuery) async throws -> [TalkData] {
        var results = try await htmlPageFetcher.getYearlyHTMLForCategory(query.category, year: query.year)
        if let searchText = query.searchText?.lowercased(), !searchText.isEmpty {
            results = results.filter { $0.title.lowercased().contains(searchText) }
        }
        return results
    }
}
