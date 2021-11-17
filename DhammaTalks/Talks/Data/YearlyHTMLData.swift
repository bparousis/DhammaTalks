//
//  File.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup

struct YearlyHTMLData {
    let html: String
    let talkCategory: DailyTalkCategory
    let year: Int
    
    private let audioFileNameParser = AudioFileNameParser()

    func parseTalkData() -> Result<[TalkData], Error> {
        var talkDataList: [TalkData] = []
        do {
            let document = try SwiftSoup.parse(html)
            try document.select("a").forEach { element in
                let hrefValue = try element.attr("href")
                if let (title, date) = audioFileNameParser.parseFileNameWithDate(hrefValue) {
                    let url = "\(talkCategory.talkURLForYear(year))/\(hrefValue)"
                    let talkData = TalkData(id: UUID().uuidString, title: title, date: date, url: url)
                    talkDataList.insert(talkData, at: 0)
                }
            }
        } catch {
            return .failure(error)
        }
        return .success(talkDataList)
    }
}
