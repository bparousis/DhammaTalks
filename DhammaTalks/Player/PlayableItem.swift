//
//  PlayableItem.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

import AVKit

protocol PlayableItem: Identifiable {

    var id: String { get }
    var title: String { get }
    var currentTime: CMTime? { get }

    func loadPlayerItem() async -> AVPlayerItem?
    func finishedPlaying(at time: CMTime, withTotal totalDuration: CMTime)
}
