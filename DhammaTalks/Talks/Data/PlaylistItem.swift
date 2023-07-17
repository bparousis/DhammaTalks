//
//  PlaylistItem.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

struct PlaylistItem: Hashable {
    let talkData: TalkData
    let order: Int16
}

extension PlaylistItem: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.talkData.id == rhs.talkData.id && lhs.order == rhs.order
    }
}
