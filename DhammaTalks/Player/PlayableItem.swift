//
//  PlayableItem.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 7/21/23.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import AVKit

protocol PlayableItem: Identifiable {

    var id: String { get }
    var title: String { get }

    func loadPlayerItem() async -> AVPlayerItem?
    func finishedPlaying(at time: CMTime, withTotal totalDuration: CMTime)
}
