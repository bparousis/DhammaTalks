//
//  MockTalkFetcher.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import Foundation

@testable import DhammaTalks

class MockTalkFetcher: TalkFetcher {
    private let testCase: TestCase

    init(testCase: TestCase) {
        self.testCase = testCase
    }

    enum TestCase {
        case noTalks
        case oneMonth
        case multipleMonths
    }

    func fetchTalkCollection(for talkCategory: DailyTalkCategory, year: Int) async -> [TalkData] {
        switch testCase {
        case .noTalks:
            return []
        case .oneMonth:
            let talkDataList = [
                TalkData(id: "1", title: "Compassion", url: "210101_Compassion.mp3"),
                TalkData(id: "2", title: "Jhana Practice", url: "210107_Jhana_Practice.mp3"),
                TalkData(id: "3", title: "What the Buddha Taught", url: "210108_What_the_Buddha_Taught.mp3")
            ]
            return talkDataList
        case .multipleMonths:
            let talkDataList = [
                TalkData(id: "1", title: "A Radiant Practice", url: "210101_A_Radiant_Practice.mp3"),
                TalkData(id: "2", title: "Going Out of Your Way", url: "210107_Going_Out_of_Your_Way.mp3"),
                
                TalkData(id: "3", title: "Your Borrowed Goods", url: "210412_Your_Borrowed_Goods.mp3"),
                TalkData(id: "4", title: "Brahmaviharas at the Breath", url: "210413_Brahmaviharas_at_the_Breath.mp3"),
                TalkData(id: "5", title: "For a Routine That Isn't Routine", url: "210414_For_a_Routine_That_Isn't_Routine.mp3"),
                TalkData(id: "6", title: "On the Surface of Things", url: "210416_On_the_Surface_of_Things.mp3"),
                TalkData(id: "7", title: "Virtue, Concentration, Discernment", url: "210417_Virtue,_Concentration,_Discernment.mp3"),
                
                TalkData(id: "8", title: "Your Ancestral Territory", url: "211018_Your_Ancestral_Territory.mp3"),
                TalkData(id: "9", title: "Fix Your Views", url: "211027_Fix_Your_Views.mp3"),
                TalkData(id: "10", title: "Joyous Endurance", url: "211029_Joyous_Endurance.mp3")
            ]
            return talkDataList
        }
    }
}
