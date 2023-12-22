//
//  PlaylistMO.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

extension PlaylistMO {
    func toDomainModel() -> Playlist {
        var playlistItemList: [TalkData] = []
        if let playlistItems = playlistItems as? NSOrderedSet {
            for item in playlistItems {
                if let playlistItem = item as? PlaylistItemMO,
                   let title = playlistItem.title, let url = playlistItem.url {
                    playlistItemList.append(TalkData(id: UUID().uuidString,
                                                     title: title,
                                                     url: url)
                    )
                }
            }
        }
        
        return Playlist(id: id!,
                        title: title ?? "",
                        desc: desc,
                        playlistItems: playlistItemList)
    }
}
