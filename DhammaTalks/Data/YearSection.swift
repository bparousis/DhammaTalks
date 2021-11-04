//
//  Year.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-02-01.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct YearSection: Identifiable {
    var id: Int
    var talks: [TalkData] = []
    
    var year: String {
        return "\(id)"
    }
}

extension YearSection: Hashable {
    static func == (lhs: YearSection, rhs: YearSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
