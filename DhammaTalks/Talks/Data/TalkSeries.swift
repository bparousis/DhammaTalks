//
//  CategoryTalks.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-06.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkSeries: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String
    let image: String
    let sections: [TalkSection]
}
