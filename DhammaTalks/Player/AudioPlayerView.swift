//
//  AudioPlayerView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

import SwiftUI
import Combine

struct AudioPlayerView: View {
    
    private struct Constants {
        static let iconFontSize: CGFloat = 25
        static let seekPadding: CGFloat = 50
        static let logoSize: CGFloat = 200
        static let buttonPadding: CGFloat = 15
        static let timeDisplayPadding: CGFloat = 10
    }

    @ObservedObject private var audioPlayer: AudioPlayer
    private var initialPlayIndex: Int

    init(audioPlayer: AudioPlayer, playIndex: Int) {
        self.audioPlayer = audioPlayer
        self.initialPlayIndex = playIndex
    }

    var sliderView: some View {
        HStack {
            Slider(value: $audioPlayer.progressTime, in: 0...audioPlayer.totalTimeInSeconds) {
                EmptyView()
            } minimumValueLabel: {
                if let currentTimeString = audioPlayer.currentTimeString {
                    Text(currentTimeString)
                        .font(.system(size: 12))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: Constants.timeDisplayPadding))
                }
            } maximumValueLabel: {
                if let timeRemainingString = audioPlayer.timeRemainingString {
                    Text(timeRemainingString)
                        .font(.system(size: 12))
                        .padding(EdgeInsets(top: 0, leading: Constants.timeDisplayPadding, bottom: 0, trailing: 0))
                }
            } onEditingChanged: { scrubStarted in
                if scrubStarted {
                    audioPlayer.isScrubbing = true
                    self.audioPlayer.pause()
                } else {
                    audioPlayer.isScrubbing = false
                    self.audioPlayer.seekTo(seconds: audioPlayer.progressTime <= 0 ? 1 : audioPlayer.progressTime)
                    Task {
                        await self.audioPlayer.play()
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .tint(.white)
            .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    var playPauseToggledButton: some View {
        if audioPlayer.showPlayButton {
            Button {
                Task {
                    await audioPlayer.play()
                }
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: Constants.iconFontSize))
            }
        } else {
            Button {
                audioPlayer.pause()
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: Constants.iconFontSize))
            }
        }
    }

    var body: some View {
        VStack {
            if let title = audioPlayer.title {
                Text(title)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding()
            } else {
                EmptyView()
            }
            Image("dtLogo")
                .resizable()
                .frame(width: Constants.logoSize, height: Constants.logoSize)
            HStack {
                Button {
                    audioPlayer.skipBackward()
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: Constants.iconFontSize))
                }
                .padding(EdgeInsets(top: 0, leading: Constants.seekPadding, bottom: 0, trailing: Constants.seekPadding))
                Button {
                    Task {
                        await audioPlayer.playPrevious()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: Constants.iconFontSize))
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: Constants.buttonPadding))
                playPauseToggledButton
                Button {
                    Task {
                        await audioPlayer.playNext()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: Constants.iconFontSize))
                }
                .padding(EdgeInsets(top: 0, leading: Constants.buttonPadding, bottom: 0, trailing: 0))
                Button {
                    audioPlayer.skipForward()
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: Constants.iconFontSize))
                }
                .padding(EdgeInsets(top: 0, leading: Constants.seekPadding, bottom: 0, trailing: Constants.seekPadding))
            }
            .padding()
            sliderView
            .padding(EdgeInsets(top:50, leading: 15, bottom: 10, trailing: 15))
        }
        .task {
            await audioPlayer.play(at: initialPlayIndex)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .presentationDragIndicator(.visible)
        .onDisappear {
            audioPlayer.finishPlaying()
        }
    }
}
