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

    func extractFromHTML(_ htmlData: HTMLData) -> [TalkData] {
        let parser = AudioFileNameParser()
        var talkDataList: [TalkData] = []

        guard let document = try? SwiftSoup.parse(htmlData.html) else {
            return []
        }

        do {
            try document.select("a").forEach { element in
                let linkUrl = try element.attr("href")
                if linkUrl.hasSuffix(".mp3"), let talkData = parser.makeTalkData(fileName: linkUrl, talkCategory: htmlData.talkCategory) {
                    talkDataList.insert(talkData, at: 0)
                }
            }
        } catch {
            print(error)
        }
        return talkDataList
    }
}
