//
//  PlaylistSelectorViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import Combine
import os.log

class PlaylistSelectorViewModel: ObservableObject {
    
    @Published var playlists: [Playlist] = []
    
    let playlistService: PlaylistService
    let talkUserInfoService: TalkUserInfoService
    let downloadManager: DownloadManager

    init(playlistService: PlaylistService,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager) {
        self.playlistService = playlistService
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }

    @MainActor
    func fetchPlaylists() async {
        playlists = await playlistService.fetchPlaylists()
    }
    
    func createPlaylist(title: String, description: String?) {
        do {
            let playlist = Playlist(id: UUID(),
                                    title: title,
                                    desc: description,
                                    playlistItems: [])
            try playlistService.createPlaylist(playlist)
        } catch {
            Logger.playlist.error("Error saving Playlist: \(String(describing: error))")
        }
    }
    
    func deletePlaylists(at indexSet: IndexSet) {
        for index in indexSet {
            do {
                try playlistService.deletePlaylist(id: playlists[index].id)
                playlists.remove(at: index)
            } catch {
                Logger.playlist.error("Error deleting Playlist: \(String(describing: error))")
            }
        }
    }
}

