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
    func fetchPlaylists() async -> [Playlist] {
        await self.managedObjectContext.perform {
            var playlists: [Playlist] = []
            let playlistFetch = NSFetchRequest<PlaylistMO>(entityName: "PlaylistMO")

            guard let results = try? self.managedObjectContext.fetch(playlistFetch) else {
                return playlists
            }

            for playlistMO in results {
                playlists.append(playlistMO.toDomainModel())
            }
            return playlists
        }
    }
    
    func createPlaylist(_ playlist: Playlist) throws {
        try managedObjectContext.performAndWait {
            let playlistMO = PlaylistMO(context: managedObjectContext)
            playlistMO.title = playlist.title
            playlistMO.desc = playlist.desc
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }
        }
    }
    
    func deletePlaylist(id: String) throws {
        
        let fetchRequest: NSFetchRequest<PlaylistMO> = PlaylistMO.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "id==\(id)")

        // Setting includesPropertyValues to false means
        // the fetch request will only get the managed
        // object ID for each object
        fetchRequest.includesPropertyValues = false

        // Get a reference to a managed object context

        // Perform the fetch request
        if let playlistToDelete = try managedObjectContext.fetch(fetchRequest).first {
            managedObjectContext.delete(playlistToDelete)
        }
    }
}

