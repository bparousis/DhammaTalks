//
//  DhammaTalksApp.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-18.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI
import UIKit
import CoreData

@main
struct DhammaTalksApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let talkUserInfoService: TalkUserInfoService
    private let talkDataService: TalkDataService
    private let downloadManager: DownloadManager
    
    init() {
        self.talkUserInfoService = TalkUserInfoService(managedObjectContext: CoreDataStack.viewContext)
        self.talkDataService = TalkDataService()
        self.downloadManager = DownloadManager()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(talkUserInfoService)
                .environmentObject(talkDataService)
                .environmentObject(downloadManager)
        }
    }
}
