//
//  Playlist.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

struct Playlist: Identifiable {
    let id: String
    let title: String
    let desc: String?
    let playlistItems: [PlaylistItem]
}
