//
//  PlaylistRowViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 7/17/23.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

import Combine

class PlaylistRowViewModel: ObservableObject {
    @Published var playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
    }
    
    var title: String {
        playlist.title
    }
    
    var descriptionText: String {
        let talksCount = "\(playlist.playlistItems.count) talks"
        if let description = playlist.desc, !description.isEmpty {
            return "\(description) • \(talksCount)"
        } else {
            return "\(talksCount)"
        }
    }
}
