//
//  MockPlayableList.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import AVFoundation

@testable import DhammaTalks

class MockPlayableList: PlayableList {
    var playableItems: [any PlayableItem]
    
    init(playableItems: [any PlayableItem]) {
        self.playableItems = playableItems
    }

    func playableItemWithID(_ id: String) -> TalkIdentifier? {
        if let index = playableItems.firstIndex(where: { $0.id == id }) {
            return TalkIdentifier(id: id, index: index)
        } else {
            return nil
        }
    }
}

class MockPlayableItem: PlayableItem {
    var id: String
    var title: String
    var currentTime: CMTime?
    
    init(id: String, title: String, currentTime: CMTime? = nil) {
        self.id = id
        self.title = title
        self.currentTime = currentTime
    }

    func loadPlayerItem() async -> AVPlayerItem? {
        AVPlayerItem(url: URL(string: "about:blank")!)
    }
    
    func finishedPlaying(at time: CMTime, withTotal totalDuration: CMTime) {
        currentTime = time
    }
}
