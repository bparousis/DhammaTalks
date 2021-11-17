//
//  AudioFileNameParser.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

class AudioFileNameParser {
    
    private struct Translation {
        let from: String
        let to: String
        
        func translate(value: String) -> String {
            value.replacingOccurrences(of: from, with: to)
        }
    }

    private let YMD = "yyMMdd"
    private let YM = "yyMM"
    private let DATE_POSITION = 0
    
    // IMPORTANT: Order matters.  For instance doing Translation(from: "_", to: " ") first would not translate correctly.
    private let translations: [Translation] = [Translation(from: "_Q.", to: "?."),
                                               Translation(from: "_Q_", to: "?_"),
                                               Translation(from: "_", to: " ")]

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
    func parseFileNameWithDate(_ fileName: String) -> (title: String, date: Date)? {

        guard fileName.hasSuffix(".mp3") else {
            return nil
        }

        var fileNameSplit = extractTextFromFileName(fileName)
        guard let dateString = validateDateString(String(fileNameSplit[DATE_POSITION])) else {
            return nil
        }

        var parsedDate: Date? = nil
        if dateString.count == YMD.count {
            parsedDate = ymdDateFormatter.date(from: dateString)
        } else if dateString.count == YM.count {
            parsedDate = ymDateFormatter.date(from: dateString)
        }
        
        guard let date = parsedDate else {
            return nil
        }
        
        fileNameSplit.removeFirst()
        let title = fileNameSplit.joined(separator: " ")
        return (title, date)
    }
}

private extension AudioFileNameParser {
    func extractTextFromFileName(_ fileName: String) -> [Substring] {
        guard var formattedFileName = fileName.removingPercentEncoding else {
            return []
        }

        for translation in translations {
            formattedFileName = translation.translate(value: formattedFileName)
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
