//
//  TalkRow.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-19.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

struct TalkRow: View {
    
    @ObservedObject var viewModel: TalkRowViewModel
    @State private var showActionSheet = false
    
    @ViewBuilder
    private var actionButton: some View {
        if viewModel.downloadProgress != nil {
            CircularProgressBar(progress: $viewModel.downloadProgress, lineWidth: 2.0) {
                viewModel.cancelDownload()
            }
            .frame(width: 25, height: 25, alignment: .center)
        } else {
            Button(action: { showActionSheet = true }) {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    @ViewBuilder
    private var playedStateView: some View {
        switch viewModel.state {
        case .played:
            Text("Played")
                 .foregroundColor(.secondary)
                 .font(.system(size: 12))
        case .inProgress:
            HStack {
                ProgressView(value: viewModel.currentTimeInSeconds, total: viewModel.totalTimeInSeconds)
                    .frame(width: 75)
                if let timeRemainingPhrase = viewModel.timeRemainingPhrase {
                    Text(timeRemainingPhrase)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
        case .unplayed:
            Text("")
                .frame(width: 0, height: 0, alignment: .top)
        }
    }
    
    var titleStatusView: some View {
        HStack(alignment: .firstTextBaseline) {
            if viewModel.dateStyle == .day {
                Text(viewModel.formattedDay ?? "  ")
                    .font(.subheadline)
            }
            Text(viewModel.title)
                .font(.headline)
            HStack(spacing: 3) {
                if viewModel.favorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color(.systemYellow))
                }
                if viewModel.isDownloadAvailable {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 11.5))
                        .foregroundColor(Color(.systemBlue))
                }
            }
        }
    }
    
    @ViewBuilder
    private var fullDateView: some View {
        if let formattedDate = viewModel.formattedDate {
            Text(formattedDate)
                .font(.subheadline)
        }
    }

    var body: some View {
        Button(action: {
            Task {
                await viewModel.play()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    titleStatusView
                    if viewModel.dateStyle == .full {
                        fullDateView
                    }
                    playedStateView
                }
                Spacer()
                actionButton
            }
        }
        .confirmationDialog(Text(viewModel.title), isPresented: $showActionSheet) {
            ForEach(viewModel.actions) { action in
                Button(action.title) {
                    viewModel.handleAction(action)
                }
            }
        }
        .foregroundColor(.primary)
        .padding(5)
        .sheet(item: $viewModel.playerItem) { item in
            MediaPlayer(playerItem: item, title: viewModel.title)
            .onDisappear{
                viewModel.finishedPlaying(item: item)
            }
        }
        .task {
            viewModel.fetchTalkInfo()
        }
    }
}
