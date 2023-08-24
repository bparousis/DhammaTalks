//
//  MockPlayableItem.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2023-08-11.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import AVKit
@testable import DhammaTalks

class MockPlayableItem: PlayableItem {
    var id: String
    
    var title: String
    
    let avPlayerItem = MockAVPlayerItem(url: URL(string: "about:blank")!)
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    var finishedPlayingCalled = false
    
    func loadPlayerItem() async -> AVPlayerItem? {
        return avPlayerItem
    }
    
    func finishedPlaying(at time: CMTime, withTotal totalDuration: CMTime) {
        self.finishedPlayingCalled = true
    }
}
