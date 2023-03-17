//
//  Array.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-06.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

extension Array where Element == TalkRowViewModel {
    func playRandom() async -> String? {
        guard let randomRow = randomElement() else {
            return nil
        }
        await randomRow.play()
        return randomRow.id
    }
}

extension Array where Element == PlaylistItem {

    func convertToTalkRowViewModelArray(talkUserInfoService: TalkUserInfoService,
                                        downloadManager: DownloadManager) -> [TalkRowViewModel]
    {
        sorted { $0.order < $1.order }
        .map{
            let viewModel = TalkRowViewModel(talkData: $0.talkData,
                                             talkUserInfoService: talkUserInfoService,
                                             downloadManager: downloadManager)
            viewModel.dateStyle = .full
            return viewModel
        }
    }
}
