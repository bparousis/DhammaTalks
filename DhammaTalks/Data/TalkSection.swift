//
//  Year.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-02-01.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkSection: Identifiable {
    var id: Int
    let title: String
    private(set) var talks: [TalkData] = []
    
    mutating func addTalk(_ talkData: TalkData) {
        talks.append(talkData)
    }
}

extension TalkSection: Hashable {
    static func == (lhs: TalkSection, rhs: TalkSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
