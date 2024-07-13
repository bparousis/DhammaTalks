//
//  PlaylistService.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-11-18.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import CoreData
import CoreMedia
import Combine

class PlaylistService: ObservableObject {

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    @MainActor
    func fetchPlaylists(sort: Sort = .createdDate) async -> [Playlist] {
        await self.managedObjectContext.perform {
            let playlistFetch = NSFetchRequest<PlaylistMO>(entityName: "PlaylistMO")
            playlistFetch.sortDescriptors = [sort.sortDescriptor]
            guard let results = try? self.managedObjectContext.fetch(playlistFetch) else {
                return []
            }
            return results.map { $0.toDomainModel() }
        }
    }
    
    @discardableResult
    func createPlaylist(_ playlist: Playlist) throws -> Bool {
        guard !playlist.title.isEmpty else {
            return false
        }

        var createResult = false
        try managedObjectContext.performAndWait {
            let playlistMO = PlaylistMO(context: managedObjectContext)
            playlistMO.id = playlist.id
            playlistMO.title = playlist.title
            playlistMO.desc = playlist.desc
            playlistMO.createdDate = playlist.createdDate
            playlistMO.lastModifiedDate = playlist.lastModifiedDate
            try managedObjectContext.save()
            createResult = true
        }
        return createResult
    }
    
    @discardableResult
    func addTalkData(_ talkData: TalkData, toPlaylistWithID playlistID: UUID) throws -> Bool {
        try managedObjectContext.performAndWait {
            guard let playlistMO = try fetchPlaylistWithID(playlistID) else {
                return false
            }
            playlistMO.lastModifiedDate = Date()
            let playlistItemMO = PlaylistItemMO(context: managedObjectContext)
            playlistItemMO.playlist = playlistMO
            playlistItemMO.title = talkData.title
            playlistItemMO.url = talkData.url
            try managedObjectContext.save()
            return true
        }
    }

    func moveItem(fromOffsets: IndexSet, toOffset: Int, playlistID: UUID) throws {
        try managedObjectContext.performAndWait {
            guard let playlistMO = try fetchPlaylistWithID(playlistID) else {
                return
            }

            var playlistItems = playlistMO.playlistItems?.array
            playlistItems?.move(fromOffsets: fromOffsets, toOffset: toOffset)
            if let playlistItems {
                playlistMO.playlistItems = NSOrderedSet(array: playlistItems)
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            }
        }
    }

    func deleteItems(fromOffsets: IndexSet, playlistID: UUID) throws {
        try managedObjectContext.performAndWait {
            guard let playlistMO = try fetchPlaylistWithID(playlistID) else {
                return
            }

            var playlistItems = playlistMO.playlistItems?.array
            playlistItems?.remove(atOffsets: fromOffsets)
            if let playlistItems {
                playlistMO.playlistItems = NSOrderedSet(array: playlistItems)
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
            }
        }
    }

    func deletePlaylist(id: UUID) throws {
        if let playlistToDelete = try fetchPlaylistWithID(id, includesPropertyValues: false) {
            managedObjectContext.delete(playlistToDelete)
        }
        
        if managedObjectContext.hasChanges {
            try managedObjectContext.save()
        }
    }
    
    private func fetchPlaylistWithID(_ id: UUID,
                                     includesPropertyValues: Bool = true) throws -> PlaylistMO?
    {
        let fetchRequest: NSFetchRequest<PlaylistMO> = PlaylistMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id==%@", id.uuidString)

        // Setting includesPropertyValues to false means
        // the fetch request will only get the managed
        // object ID for each object
        fetchRequest.includesPropertyValues = includesPropertyValues

        // Perform the fetch request
        return try managedObjectContext.fetch(fetchRequest).first
    }
}

