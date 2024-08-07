//
//  MediaPlayer.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-20.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import SwiftUI
import AVKit

struct MediaPlayer: UIViewControllerRepresentable {
    
    private let playerItem: AVPlayerItem
    private let title: String
    
    private var playerImage: UIImage {
        let image = UIImage(named: "dtLogo")!
        let targetSize = CGSize(width: 250, height: 250)
        return image.scalePreservingAspectRatio(targetSize: targetSize)
    }
    
    private var player: AVPlayer {
        AVPlayer(playerItem: playerItem)
    }

    init(playerItem: AVPlayerItem, title: String) {
        self.playerItem = playerItem
        self.title = title
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MediaPlayer>) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.exitsFullScreenWhenPlaybackEnds = true
        return playerVC
    }

    func updateUIViewController(_ viewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<MediaPlayer>) {
        viewController.player = player

        if let view = viewController.contentOverlayView {
            if #unavailable(iOS 16.0) {
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            let imageView = UIImageView(image: playerImage)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageView)
            let titleLabel = UILabel(frame: .zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.textColor = .lightText
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 2
            titleLabel.font = .systemFont(ofSize: 30)
            view.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 290),
                imageView.heightAnchor.constraint(equalToConstant: 290),
                titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -20),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ])
        }
        viewController.player?.play()
    }
}
