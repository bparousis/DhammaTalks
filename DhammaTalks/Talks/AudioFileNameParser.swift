//
//  AudioFileNameParser.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct AudioFileNameParser {
    
    private struct Translation {
        let from: String
        let to: String
        
        func translate(value: String) -> String {
            value.replacingOccurrences(of: from, with: to)
        }
    }

    private static let DATE_POSITION = 0
    
    // IMPORTANT: Order matters.  For instance doing Translation(from: "_", to: " ") first would not translate correctly.
    private static let translations: [Translation] = [Translation(from: "_Q.", to: "?."),
                                               Translation(from: "_Q_", to: "?_"),
                                               Translation(from: "_", to: " ")]

    /// Returns nil if the URL isn't in date format. (e.g. https://www.dhammatalks.org/Archive/y2021/210101_A_Radiant_Practice.mp3)
    static func extractTitleAndFilename(_ urlString: String) -> (title: String, filename: String)? {

        guard urlString.hasSuffix(".mp3") else {
            return nil
        }

        let filename = formatFilename(urlString)
        var filenameSplit = extractTextFromFilename(filename)
        filenameSplit.removeFirst()
        let title = filenameSplit.joined(separator: " ")
        return (title, filename)
    }
    
    static func extractDate(_ urlString: String) -> Date? {
        let filename = formatFilename(urlString)

        let filenameSplit = extractTextFromFilename(filename)
        guard let dateString = validateDateString(String(filenameSplit[DATE_POSITION])) else {
            return nil
        }

        var parsedDate: Date? = nil
        if dateString.count == DateFormatter.YMD.count {
            parsedDate = DateFormatter.ymdDateFormatter.date(from: dateString)
        } else if dateString.count == DateFormatter.YM.count {
            parsedDate = DateFormatter.ymDateFormatter.date(from: dateString)
        }
        return parsedDate
    }
}

private extension AudioFileNameParser {
    
    static func formatFilename(_ filename: String) -> String{
        if let lastSlashIndex = filename.lastIndex(of: "/") {
            let afterSlashIndex = filename.index(after: lastSlashIndex)
            return String(filename[afterSlashIndex...])
        } else {
            return filename
        }
    }

    static func extractTextFromFilename(_ filename: String) -> [Substring] {

        guard var formattedFilename = filename.removingPercentEncoding else {
            return []
        }

        for translation in translations {
            formattedFilename = translation.translate(value: formattedFilename)
        }
        
        formattedFilename.removeLast(".mp3".count)
        if formattedFilename.last == "Q" {
            formattedFilename.removeLast()
            formattedFilename.append("?")
        }
        return formattedFilename.split(separator: " ")
    }

    static func validateDateString(_ dateString: String) -> String? {
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
