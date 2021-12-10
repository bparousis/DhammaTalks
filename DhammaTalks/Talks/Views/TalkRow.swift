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
    @State var showActionSheet = false
    
    var actionButton: some View {
        HStack {
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
    }
    
    var statusView: some View {
        HStack(spacing: 10) {
            if viewModel.isDownloadAvailable {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(Color(.systemBlue))
            }
            switch viewModel.state {
            case .played:
                Text("Played")
                     .foregroundColor(.secondary)
                     .font(.system(size: 12))
            case .inProgress:
                ProgressView(value: viewModel.currentTimeInSeconds, total: viewModel.totalTimeInSeconds)
                    .frame(width: 75)
                if let timeRemainingPhrase = viewModel.timeRemainingPhrase {
                    Text(timeRemainingPhrase)
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            case .unplayed:
                Text("")
                    .frame(width: 0, height: 0, alignment: .top)
            }
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
                    Text(viewModel.title)
                        .font(.headline)
                    if let formattedDate = viewModel.formattedDate {
                        Text(formattedDate)
                            .font(.subheadline)
                    }
                    statusView
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
            viewModel.fetchTalkTime()
        }
    }
}
