//
//  TalkUserInfoService.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-26.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import CoreData
import CoreMedia
import Combine

class TalkUserInfoService: ObservableObject {
    
    var savePublisher: AnyPublisher<TalkUserInfo, Never> {
        saveSubject.eraseToAnyPublisher()
    }
    
    private let managedObjectContext: NSManagedObjectContext
    private let saveSubject = PassthroughSubject<TalkUserInfo, Never>()
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func getTalkUserInfo(for url: String) -> TalkUserInfo? {
        var talkUserInfo: TalkUserInfo?
        managedObjectContext.performAndWait {
            let talkUserInfoFetch = NSFetchRequest<TalkUserInfoMO>(entityName: "TalkUserInfoMO")
            talkUserInfoFetch.predicate = NSPredicate(format: "url == %@", url)
            guard let results = try? managedObjectContext.fetch(talkUserInfoFetch), let talkUserInfoMO = results.first else {
                return
            }
            talkUserInfo = talkUserInfoMO.toDomainModel()
        }
        return talkUserInfo
    }

    func save(talkUserInfo: TalkUserInfo) throws {
        try managedObjectContext.performAndWait {
            let talkUserInfoMO = TalkUserInfoMO(context: managedObjectContext)
            talkUserInfoMO.url = talkUserInfo.url
            talkUserInfoMO.currentTimeValue = talkUserInfo.currentTime.value
            talkUserInfoMO.currentTimeScale = talkUserInfo.currentTime.timescale
            talkUserInfoMO.totalTimeValue = talkUserInfo.totalTime.value
            talkUserInfoMO.totalTimeScale = talkUserInfo.totalTime.timescale
            talkUserInfoMO.notes = talkUserInfo.notes
            if let favoriteDetails = talkUserInfo.favoriteDetails {
                let favoriteDetailsMO = FavoriteDetailsMO(context: managedObjectContext)
                favoriteDetailsMO.title = favoriteDetails.title
                favoriteDetailsMO.dateAdded = favoriteDetails.dateAdded
                talkUserInfoMO.favoriteDetails = favoriteDetailsMO
            }
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }
            saveSubject.send(talkUserInfo)
        }
    }
    
    @MainActor
    func fetchFavoriteTalks(searchText: String) async -> [TalkData] {
        await managedObjectContext.perform { [weak self] in
            guard let self else { return [] }
            var favoritesList: [TalkData] = []
            let talkUserInfoFetch = NSFetchRequest<TalkUserInfoMO>(entityName: "TalkUserInfoMO")
            var predicates: [NSPredicate] = [NSPredicate(format: "favoriteDetails != nil")]
            if !searchText.isEmpty {
                predicates.append(NSPredicate(format: "favoriteDetails.title contains[cd] %@", searchText))
            }
            talkUserInfoFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            talkUserInfoFetch.sortDescriptors = [NSSortDescriptor(key: "favoriteDetails.dateAdded", ascending: false)]
            guard let results = try? self.managedObjectContext.fetch(talkUserInfoFetch) else {
                return favoritesList
            }

            for talkUserInfoMO in results {
                if let url = talkUserInfoMO.url, let title = talkUserInfoMO.favoriteDetails?.title {
                    favoritesList.append(TalkData(id: UUID().uuidString, title: title, url: url))
                }
            }
            return favoritesList
        }
    }
}
