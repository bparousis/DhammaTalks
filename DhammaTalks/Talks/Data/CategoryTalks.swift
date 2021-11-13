//
//  CategoryTalks.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-06.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

struct CategoryTalks: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let talks: [TalkData]
    
    private enum CodingKeys: String, CodingKey {
        case title, talks
    }
}
