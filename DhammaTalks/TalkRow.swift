//
//  TalkRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import AVKit

struct TalkRow: View {

    let talk: TalkData
    @State private var selected = false
    @State private var player: AVPlayer?
    @State private var showingPlayer = false

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter
    }
    
    init(talk: TalkData) {
        self.talk = talk
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(talk.title)").font(.headline)
                if let date = talk.date {
                    Text("\(self.dateFormatter.string(from: date))").font(.subheadline)
                }
            }
            Spacer()
            Image(systemName: "play")
        }.padding(5)
         .onTapGesture {
            self.showingPlayer = true
        }.sheet(isPresented: $showingPlayer) {
            if let talkURL = URL(string: self.talk.url) {
                PlayerVC(url: talkURL, title: self.talk.title)
            }
        }
    }
}

struct PlayerVC: UIViewControllerRepresentable {
    
    private let url: URL
    private let title: String
    
    private var playerImage: UIImage {
        let image = UIImage(named: "dtLogo")!
        let targetSize = CGSize(width: 250, height: 250)
        return image.scalePreservingAspectRatio(targetSize: targetSize)
    }
    
    private var player: AVPlayer {
        let artwork = AVMutableMetadataItem()
        artwork.key = AVMetadataKey.commonKeyArtwork as NSCopying & NSObjectProtocol
        artwork.keySpace = AVMetadataKeySpace.common
        artwork.value = playerImage.pngData() as (NSCopying & NSObjectProtocol)?
        artwork.locale = .current
        let playerItem = AVPlayerItem(url: url)
        playerItem.externalMetadata = [artwork]
        return AVPlayer(playerItem: playerItem)
    }

    init(url: URL, title: String) {
        self.url = url
        self.title = title
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PlayerVC>) -> AVPlayerViewController {
        return AVPlayerViewController()
    }

    func updateUIViewController(_ viewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<PlayerVC>) {
        viewController.player = player
        
        if let view = viewController.contentOverlayView {
            view.translatesAutoresizingMaskIntoConstraints = false
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
                titleLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -20),
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            ])
        }
        viewController.player?.play()
    }
}


extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
