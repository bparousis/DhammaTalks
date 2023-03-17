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
    
    
//    [Playlist(id: "1", title: "Emotions", desc: "Talks on emotions", playlistItems: [PlaylistItem(talkData: TalkData(title: "Mental Karma", url: "y2023/230101_Mental_Karma.mp3"), order: 1), PlaylistItem(talkData: TalkData(title: "A Year That's Always New", url: "shorttalks/y2023/230101(short)_A_Year_That's_Always_New.mp3"), order: 1)]),
//                                            Playlist(id: "2", title: "Meditation", desc: "Talks on meditation", playlistItems: [])]
    
    private let playlistService: PlaylistService
    let talkUserInfoService: TalkUserInfoService
    let downloadManager: DownloadManager

    init(playlistService: PlaylistService,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager) {
        self.playlistService = playlistService
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
    }
    
    func fetchPlaylists() async {
        playlists = await playlistService.fetchPlaylists()
    }
    
    func createPlaylist(title: String, description: String?) {
        do {
            let playlist = Playlist(id: UUID().uuidString, title: title,
                                    desc: description, playlistItems: [])
            try playlistService.createPlaylist(playlist)
        } catch {
            Logger.playlist.error("Error saving Playlist: \(String(describing: error))")
        }
    }
    
    func deletePlaylists(at indexSet: IndexSet) {
        for index in indexSet {
//            playlists[index].id
        }
    }
}

