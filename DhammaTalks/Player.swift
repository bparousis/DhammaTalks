//
//  Player.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import AVFoundation

class Player {

    private var player: AVPlayer?

    func play(url: URL) {
        let playerItem = AVPlayerItem(url: url)

        self.player = AVPlayer(playerItem: playerItem)
        player?.volume = 1.0
        player?.play()
    }
}
