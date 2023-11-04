//
//  Year.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-02-01.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkSection: Identifiable, Decodable {
    let id: String
    let title: String?
    private(set) var talks: [SeriesTalkData] = []

    mutating func addTalk(_ talkData: SeriesTalkData) {
        talks.append(talkData)
    }
}

extension TalkSection: Equatable {
    static func == (lhs: TalkSection, rhs: TalkSection) -> Bool {
        return lhs.id == rhs.id
    }
}
