//
//  PlaylistViewModel.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-02-25.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation
import Combine

import os.log

enum SortType {
    case name
    case createdData
    case lastModifiedDate
    
}

class PlaylistViewModel: ObservableObject {
    @Published var playlistItems: [TalkRowViewModel] = []
    private let playlist: Playlist
    private let talkUserInfoService: TalkUserInfoService
    private let downloadManager: DownloadManager
    private let playlistService: PlaylistService
    
    var title: String {
        playlist.title
    }
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        talkUserInfoService.savePublisher
    }
    
    init(playlist: Playlist,
         talkUserInfoService: TalkUserInfoService,
         downloadManager: DownloadManager,
         playlistService: PlaylistService) {
        self.playlist = playlist
        self.talkUserInfoService = talkUserInfoService
        self.downloadManager = downloadManager
        self.playlistService = playlistService
    }
    
    public func loadPlaylistItems() {
        self.playlistItems = fetchPlaylistItems()
    }

    private func fetchPlaylistItems() -> [TalkRowViewModel] {
        playlist
            .playlistItems
            .map {
                let viewModel = TalkRowViewModel(talkData: $0,
                                                 talkUserInfoService: talkUserInfoService,
                                                 downloadManager: downloadManager,
                                                 playlistService: playlistService)
                viewModel.dateStyle = .full
                viewModel.playlist = playlist
                return viewModel
            }
    }

    func playRandomTalk() async -> String? {
        return await playlistItems.playRandom()
    }

    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        do {
            try playlistService.moveItem(fromOffsets: fromOffsets, toOffset: toOffset, playlistID: playlist.id)
            playlistItems.move(fromOffsets: fromOffsets, toOffset: toOffset)
        } catch {
            Logger.playlist.error("Error moving playlist item: \(String(describing: error))")
        }
    }

    func deleteItems(fromOffsets: IndexSet) {
        do {
            try playlistService.deleteItems(fromOffsets: fromOffsets, playlistID: playlist.id)
            playlistItems.remove(atOffsets: fromOffsets)
        } catch {
            Logger.playlist.error("Error deleting playlist item: \(String(describing: error))")
        }
    }

    func searchPlaylistItems(searchText: String) {
        let formattedSearchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var searchedItems = fetchPlaylistItems()
        if !formattedSearchText.isEmpty {
            searchedItems = searchedItems.filter {
                $0.title.lowercased().contains(formattedSearchText)
            }
        }
        playlistItems = searchedItems
    }
}
