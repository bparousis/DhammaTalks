//
//  CollectionResponse.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-10-28.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

struct CollectionResponse: Decodable {
    let statusCode: Int
    let body: [CollectionTalkData]
}
