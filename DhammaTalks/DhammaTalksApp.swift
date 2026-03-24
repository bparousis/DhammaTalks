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
    private let playlistService: PlaylistService
    private let audioPlayer: AudioPlayer
    
    init() {
        self.talkUserInfoService = TalkUserInfoService(managedObjectContext: CoreDataStack.viewContext)
        self.talkDataService = TalkDataService()
        self.downloadManager = DownloadManager()
        self.playlistService = PlaylistService(managedObjectContext: CoreDataStack.viewContext)
        self.audioPlayer = AudioPlayer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(talkUserInfoService)
                .environmentObject(talkDataService)
                .environmentObject(downloadManager)
                .environmentObject(playlistService)
                .environmentObject(audioPlayer)
        }
    }
}
