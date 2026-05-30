//
//  AudioPlayerView.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

struct AudioPlayerView: View {
    
    private struct Constants {
        static let iconFontSize: CGFloat = 25
        static let seekPadding: CGFloat = 50
        static let logoSize: CGFloat = 200
        static let buttonPadding: CGFloat = 15
        static let timeDisplayPadding: CGFloat = 10
    }

    @ObservedObject private var audioPlayer: AudioPlayer
    
    @State private var showSpeedPicker = false
    @State private var autoplay = AppSettings.autoplay
    
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
                        .opacity(0.85)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: Constants.timeDisplayPadding))
                }
            } maximumValueLabel: {
                if let totalTimeString = audioPlayer.totalTimeString {
                    Text(totalTimeString)
                        .font(.system(size: 12))
                        .opacity(0.85)
                        .padding(EdgeInsets(top: 0, leading: Constants.timeDisplayPadding, bottom: 0, trailing: 0))
                }
            } onEditingChanged: { scrubStarted in
                if scrubStarted {
                    audioPlayer.isScrubbing = true
                    if audioPlayer.status == .playing {
                        self.audioPlayer.pause()
                    }
                } else {
                    audioPlayer.isScrubbing = false
                    self.audioPlayer.seekTo(seconds: audioPlayer.progressTime <= 0 ? 0 : audioPlayer.progressTime)
                    Task {
                        await self.audioPlayer.play()
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .tint(Color.primaryTheme)
            .foregroundColor(Color.primaryTheme)
            .opacity(audioPlayer.showProgress ? 1 : 0)
        }
    }
    
    @ViewBuilder
    var playPauseToggledButton: some View {
        Button {
            Task {
                if audioPlayer.showPlayButton {
                    await audioPlayer.play()
                } else {
                    audioPlayer.pause()
                }
            }
        } label: {
            ZStack {
                Circle().stroke(Color.primaryTheme, lineWidth: 2)
                Image(systemName: audioPlayer.showPlayButton ? "play.fill" : "pause.fill")
                    .foregroundStyle(Color.primaryTheme)
                    .font(.system(size: Constants.iconFontSize + 15))
            }
            .frame(width: Constants.iconFontSize + 40, height: Constants.iconFontSize + 40)
        }
        .disabled(!audioPlayer.showProgress)
    }

    var body: some View {
        VStack(spacing: 10) {
            if let title = audioPlayer.title {
                Text(title)
                    .foregroundStyle(Color.primaryTheme)
                    .tracking(2)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 28, weight: .semibold))
                    .padding(EdgeInsets(top:20, leading: 50, bottom: 40, trailing: 50))
            } else {
                EmptyView()
            }
            
            ZStack {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.primaryTheme.opacity(0.5),
                        Color(UIColor.systemBackground).opacity(0.0)
                    ]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 150
                )
                .blendMode(.screen)
                .blur(radius: 40)
                
                Image("dtLogo-transparent")
                    .resizable()
                    .opacity(0.7)
                    .frame(width: Constants.logoSize, height: Constants.logoSize)
            }
            .frame(width: Constants.logoSize + 100, height: Constants.logoSize + 100)

            HStack {
                Button {
                    audioPlayer.skipBackward()
                } label: {
                    Image(systemName: "gobackward.15")
                        .foregroundStyle(Color.primaryTheme)
                        .font(.system(size: Constants.iconFontSize))
                }
                .disabled(!audioPlayer.showProgress)
                .padding(EdgeInsets(top: 0, leading: Constants.seekPadding, bottom: 0, trailing: Constants.seekPadding))
                Button {
                    Task {
                        await audioPlayer.playPrevious()
                    }
                } label: {
                    Image(systemName: "backward.fill")
                        .foregroundStyle(Color.primaryTheme)
                        .font(.system(size: Constants.iconFontSize))
                }
                .disabled(!audioPlayer.showProgress)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: Constants.buttonPadding))
                playPauseToggledButton
                Button {
                    Task {
                        await audioPlayer.playNext()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                        .foregroundStyle(Color.primaryTheme)
                        .font(.system(size: Constants.iconFontSize))
                }
                .disabled(!audioPlayer.showProgress)
                .padding(EdgeInsets(top: 0, leading: Constants.buttonPadding, bottom: 0, trailing: 0))
                Button {
                    audioPlayer.skipForward()
                } label: {
                    Image(systemName: "goforward.15")
                        .foregroundStyle(Color.primaryTheme)
                        .font(.system(size: Constants.iconFontSize))
                }
                .disabled(!audioPlayer.showProgress)
                .padding(EdgeInsets(top: 0, leading: Constants.seekPadding, bottom: 0, trailing: Constants.seekPadding))
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
            
            VStack(spacing: 10) {

                HStack(spacing: 10) {

                    Button {
                        showSpeedPicker = true
                    } label: {
                        Text(AppSettings.playbackRate.pillLabel)
                            .font(.subheadline)
                            .foregroundColor(.brown.opacity(0.85))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color(UIColor.secondarySystemFill))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 6) {
                        if autoplay {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                        }

                        Text("Continuous")
                    }
                    .foregroundColor(.brown.opacity(0.85))
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(UIColor.secondarySystemFill))
                    .clipShape(Capsule())
                    .animation(.easeInOut(duration: 0.25), value: autoplay)
                    .onTapGesture {
                        autoplay.toggle()
                        AppSettings.autoplay = autoplay
                    }
                }
                .frame(maxWidth: .infinity)

                if let nextPlayableItem = audioPlayer.nextPlayableItem,
                   autoplay {

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Up next")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(nextPlayableItem.title)
                            .font(.subheadline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    .padding(.top, 10)
                    .foregroundColor(.brown.opacity(0.85))
                    .frame(maxWidth: 220, alignment: .leading)
                    .transition(
                        .opacity.combined(with: .move(edge: .top))
                    )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: autoplay)

            sliderView
            .padding(EdgeInsets(top:35, leading: 40, bottom: 10, trailing: 40))
        }
        .task {
            await audioPlayer.play(at: initialPlayIndex)
        }
        .sheet(isPresented: $showSpeedPicker) {
            VStack(spacing: 20) {
                Text("Playback Speed")
                    .font(.headline)
                List {
                    let currentPlaybackRate = AppSettings.playbackRate
                    ForEach(AudioPlayer.playbackSpeeds, id: \.self) { playbackSpeed in
                        Button {
                            audioPlayer.setPlaybackSpeed(playbackSpeed)
                            showSpeedPicker = false
                        } label: {
                            HStack {
                                Text(playbackSpeed.label)
                                    .font(.title3)
                                if playbackSpeed == currentPlaybackRate {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .padding()
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .presentationDragIndicator(.visible)
    }
}
