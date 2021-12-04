//
//  TestCoreDataStack.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-12-03.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import CoreData

class TestCoreDataStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "DhammaTalks")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
