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
        var playlistItemList: [PlaylistItem] = []
        if let playlistItems = playlistItems as? Set<PlaylistItemMO> {
            let items = Array(playlistItems).sorted { $0.order > $1.order }
            for item in items {
                if let title = item.title, let url = item.url {
                    
                    playlistItemList.append(
                        PlaylistItem(talkData: TalkData(title: title, url: url),
                                     order: item.order)
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
