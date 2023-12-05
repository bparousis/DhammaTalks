//
//  SeriesTalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-10-29.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

struct SeriesTalkData: Identifiable, Decodable {

    let id: String
    let title: String
    let url: String
    
    init(id: String, title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
    }
}
