//
//  TalkFetcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-11-03.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

protocol TalkFetcher {
    func fetchTalkCollection(for talkCategory: DailyTalkCategory, year: Int) async -> [TalkData]
}
