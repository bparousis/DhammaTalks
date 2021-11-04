//
//  AVPlayerView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-02-09.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
  }

  func makeUIView(context: Context) -> UIView {
    return PlayerUIView(frame: .zero)
  }
}

class PlayerUIView: UIView {
  private let playerLayer = AVPlayerLayer()

  override init(frame: CGRect) {
    super.init(frame: frame)

    let url = URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
    let player = AVPlayer(url: url)
    player.play()

    playerLayer.player = player
    layer.addSublayer(playerLayer)
  }

  required init?(coder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = bounds
  }
}
