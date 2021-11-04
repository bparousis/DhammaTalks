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

    func fetchTalks(yearRange: ClosedRange<Int>) -> [YearSection] {
        var talkData: [YearSection] = []

        for year in yearRange {
            var yearSection = YearSection(id: year)
            var talkDataList: [TalkData] = []
            guard let pageUrl = URL(string: "https://www.dhammatalks.org/Archive/y\(year)/") else {
                continue
            }

            if let html = try? String(contentsOf: pageUrl, encoding: .utf8) {
                guard let document = try? SwiftSoup.parse(html) else {
                    continue
                }

                do {
                    try document.select("a").forEach { element in
                        let linkUrl = try element.attr("href")
                        if linkUrl.hasSuffix(".mp3"), let talkData =
                            parser.parseFileName(fileName: linkUrl) {
                            talkDataList.append(talkData)
                        }
                    }
                } catch {
                }
                yearSection.talks = talkDataList.reversed()
                talkData.append(yearSection)
            }
        }

        return talkData.sorted { $0.year > $1.year }
    }
}
