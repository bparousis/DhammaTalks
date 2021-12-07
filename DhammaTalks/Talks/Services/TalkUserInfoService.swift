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

class TalkUserInfoService {
    
    private let managedObjectContext: NSManagedObjectContext
    
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
            talkUserInfoMO.downloadPath = talkUserInfo.downloadPath
            talkUserInfoMO.starred = talkUserInfo.starred
            talkUserInfoMO.currentTimeValue = talkUserInfo.currentTime.value
            talkUserInfoMO.currentTimeScale = talkUserInfo.currentTime.timescale
            talkUserInfoMO.totalTimeValue = talkUserInfo.totalTime.value
            talkUserInfoMO.totalTimeScale = talkUserInfo.totalTime.timescale
            if managedObjectContext.hasChanges {
                try managedObjectContext.save()
            }
        }
    }
}

extension TalkUserInfoMO {
    func toDomainModel() -> TalkUserInfo {
        let currentCMTime = CMTime(value: currentTimeValue, timescale: currentTimeScale)
        let totalCMTime = CMTime(value: totalTimeValue, timescale: totalTimeScale)
        
        return TalkUserInfo(url: url ?? "", currentTime: currentCMTime, totalTime: totalCMTime, starred: starred,
                            downloadPath: downloadPath)
    }
}
