//
//  View.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-03-26.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import SwiftUI

extension View {

    var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var swipeBar: some View {
        Color.secondary.ignoresSafeArea()
            .cornerRadius(8.0)
            .frame(width: 100, height: 5, alignment: .center)
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    func makeAudioPlayerView(audioPlayer: AudioPlayer) -> some View {
        if isIpad {
            AudioPlayerView(audioPlayer: audioPlayer)
        } else {
            VStack {
                swipeBar
                AudioPlayerView(audioPlayer: audioPlayer)
            }
        }
    }
}
