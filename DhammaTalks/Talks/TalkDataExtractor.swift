//
//  TalkDataExtractor.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftSoup

struct TalkDataExtractor {
    
    private let audioFileNameParser = AudioFileNameParser()

    func extractTalkDataFromHTML(_ htmlData: YearlyHTMLData) -> Result<[TalkData], Error> {
        var talkDataList: [TalkData] = []
        do {
            let document = try SwiftSoup.parse(htmlData.html)
            try document.select("a").forEach { element in
                let linkUrl = try element.attr("href")
                if linkUrl.hasSuffix(".mp3"), let talkData = audioFileNameParser.parse(fileName: linkUrl, talkCategory: htmlData.talkCategory, year: htmlData.year) {
                    talkDataList.insert(talkData, at: 0)
                }
            }
        } catch {
            return .failure(error)
        }
        return .success(talkDataList)
    }
}
