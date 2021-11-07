//
//  AudioFileNameParser.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

/**
 * Created by bparousis on 2018-06-21.
 */
class AudioFileNameParser {

    private let YMD = "yyMMdd"
    private let YM = "yyMM"
    private let DATE_POSITION = 0
    
    private let translationMap: [String: String] = [
        "_Q.": "?.",
        "_Q_": "?_",
        "_"  : " "
    ]
    
    private lazy var ymdDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = YMD
        return dateFormatter
    }()
    
    private lazy var ymDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = YM
        return dateFormatter
    }()

    /// Returns nil if the URL isn't in date format. (e.g. https://www.dhammatalks.org/Archive/y2021/210101_A_Radiant_Practice.mp3)
    func parseFileNameWithDate(fileName: String) -> TalkData? {

        guard fileName.hasSuffix(".mp3") else {
            return nil
        }

        var talkData: TalkData? = nil

        var fileNameSplit = extractTextFromFileName(fileName)
        guard let dateString = validateDateString(String(fileNameSplit[DATE_POSITION])) else {
            return nil
        }

        var date: Date? = nil
        if dateString.count == YMD.count {
            date = ymdDateFormatter.date(from: dateString)
        } else if dateString.count == YM.count {
            date = ymDateFormatter.date(from: dateString)
        }

        if let date = date {
            fileNameSplit.removeFirst()
            let title = fileNameSplit.joined(separator: " ")
            let year = Calendar.current.component(.year, from: date)
            let url = "\(TalkDataService.dhammaTalksArchiveAddress)/y\(year)/\(fileName)"
            let image = ""
            talkData = TalkData(title: title, date: date, url: url, image: image)
        }

        return talkData
    }
}

private extension AudioFileNameParser {
    func extractTextFromFileName(_ fileName: String) -> [Substring] {
        guard var formattedFileName = fileName.removingPercentEncoding else {
            return []
        }

        for translation in translationMap {
            formattedFileName = formattedFileName.replacingOccurrences(of: translation.key, with: translation.value)
        }
        
        formattedFileName.removeLast(".mp3".count)
        if formattedFileName.last == "Q" {
            formattedFileName.removeLast()
            formattedFileName.append("?")
        }
        return formattedFileName.split(separator: " ")
    }

    func validateDateString(_ dateString: String) -> String? {
        var positionIndex = dateString.startIndex
        for dateChar in dateString {
            if dateChar.isWholeNumber {
                positionIndex = dateString.index(after: positionIndex)
            } else {
                break
            }
        }

        return positionIndex == dateString.startIndex ? nil :
            String(dateString.prefix(upTo: positionIndex))
    }
}
