//
//  Year.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-02-01.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkSection: Identifiable, Decodable {
    let id: UUID = UUID()
    let title: String?
    private(set) var talks: [TalkData] = []
    
    private enum CodingKeys: String, CodingKey {
        case title, talks
    }
    
    mutating func addTalk(_ talkData: TalkData) {
        talks.append(talkData)
    }
}

extension TalkSection: Equatable {
    static func == (lhs: TalkSection, rhs: TalkSection) -> Bool {
        return lhs.id == rhs.id
    }
}
