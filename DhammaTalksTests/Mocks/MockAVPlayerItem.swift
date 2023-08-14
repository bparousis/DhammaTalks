//
//  MockAVPlayerItem.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2023-08-12.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import AVFoundation

class MockAVPlayerItem: AVPlayerItem {
    override var duration: CMTime {
        CMTime(value: 25485834786, timescale: 1000000000)
    }
}
