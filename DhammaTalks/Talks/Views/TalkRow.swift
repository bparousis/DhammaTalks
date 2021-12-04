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
    @State var showPopover = false

    var body: some View {
        
        Button(action: {
            Task {
                await viewModel.play()
            }
        }) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 10) {
                        Text(viewModel.title)
                            .font(.headline)
                        if viewModel.starred {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    Text(viewModel.formattedDate ?? "")
                        .font(.subheadline)
                    Spacer()
                    HStack(spacing: 10) {
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
                Spacer()
                Button(action: { showPopover = true }) {
                    Image(systemName: "ellipsis")
                }
                .popover(isPresented: $showPopover) {
                    List {
                        // TODO: Place holder for options
                        Text("Option 1")
                        Text("Option 2")
                    }
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
