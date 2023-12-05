//
//  CollectionTalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-10-28.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

struct CollectionTalkData: Decodable, Identifiable {

    let id: String
    let year: Int
    let month: Int
    let day: Int
    let streamingLink: String
    let talkTitle: String
    let transcribeLink: String
    let collection: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case year
        case month
        case day
        case streamingLink
        case talkTitle
        case transcribeLink
        case collection
    }
    
    var date: Date? {
        guard isYearValid, isMonthValid else {
            return nil
        }

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        if isDayValid {
            dateComponents.day = day
        }
        return Calendar(identifier: .gregorian).date(from: dateComponents)
    }

    var url: String {
        let range = streamingLink.index(streamingLink.startIndex,
                                        offsetBy: TalkData.archivePath.count + 1)..<streamingLink.endIndex
        return String(streamingLink[range]).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var isDayValid: Bool {
        (1...31).contains(day)
    }
    
    var isMonthValid: Bool {
        (1...12).contains(month)
    }
    
    var isYearValid: Bool {
        (2000...).contains(year)
    }
}
