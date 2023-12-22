//
//  Playlist.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

struct Playlist: Identifiable {
    let id: UUID
    let title: String
    let desc: String?
    let playlistItems: [TalkData]
}

extension Playlist: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Playlist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
