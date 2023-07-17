//
//  PlaylistRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-07-15.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import SwiftUI

struct PlaylistRow: View {
    
    let playlist: Playlist
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(playlist.title)
                    .font(.headline)
                HStack {
                    let talksCount = "\(playlist.playlistItems.count) talks"
                    if let description = playlist.desc, !description.isEmpty {
                        Text("\(description) • \(talksCount)")
                    } else {
                        Text("\(talksCount)")
                    }
                }
                .font(.subheadline)
            }
        }
    }
}
