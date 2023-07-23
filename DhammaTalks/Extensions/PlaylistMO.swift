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
            for playlistItem in playlistItems {
                if let title = playlistItem.title, let url = playlistItem.url {
                    playlistItemList.append(
                        PlaylistItem(talkData: TalkData(title: title, url: url),
                                     order: playlistItem.order)
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
