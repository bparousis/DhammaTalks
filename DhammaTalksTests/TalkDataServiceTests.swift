//
//  TalkDataServiceTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import XCTest
@testable import DhammaTalks

class TalkDataServiceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testError() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .error))
        var fetchError: Error? = nil
        do {
            _ = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        } catch {
            fetchError = error
        }
        XCTAssertNotNil(fetchError)
        XCTAssertEqual(fetchError as! HTMLPageFetcher.HTMLPageFetcherError, HTMLPageFetcher.HTMLPageFetcherError.failedToRetrieve)
    }
    
    func testNoTalks() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .noTalks))
        let result = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        XCTAssertEqual(result.count, 0)
    }

    func testOneMonthWithTalksWithSearch() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .oneMonth))
        var talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        XCTAssertEqual(talkDataList.count, 3)

        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "practice"))
        XCTAssertEqual(talkDataList.count, 1)
        
        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "car"))
        XCTAssertEqual(talkDataList.count, 0)
    }

    func testMultipleMonthsWithTalksWithSearch() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .multipleMonths))
        var talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        XCTAssertEqual(talkDataList.count, 10)

        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "out"))
        XCTAssertEqual(talkDataList.count, 2)
        
        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "your"))
        XCTAssertEqual(talkDataList.count, 4)
        
        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "car"))
        XCTAssertEqual(talkDataList.count, 0)
    }
    
    func testTalkSeriesList() {
        let talkSeriesList = TalkDataService.talkSeriesList!
        XCTAssertEqual(talkSeriesList.count, 9)
        XCTAssertEqual(talkSeriesList[0].sections.count, 1)
        XCTAssertEqual(talkSeriesList[0].sections[0].talks.count, 50)
        XCTAssertEqual(talkSeriesList[8].sections.count, 7)
    }
}

class MockHTMLPageFetcher: HTMLPageFetcher {
    private let testCase: TestCase

    init(testCase: TestCase) {
        self.testCase = testCase
    }

    enum TestCase {
        case error
        case noTalks
        case oneMonth
        case multipleMonths
    }

    override func getYearlyHTMLForCategory(_ category: DailyTalkCategory, year: Int) async throws -> [TalkData] {
        switch testCase {
        case .error:
            throw HTMLPageFetcherError.failedToRetrieve
        case .noTalks:
            return []
        case .oneMonth:
            let talkDataList = [
                TalkData(id: "1", title: "Compassion", date: DateFormatter.ymdDateFormatter.date(from: "210101"), url: "210101_Compassion.mp3"),
                TalkData(id: "2", title: "Jhana Practice", date: DateFormatter.ymdDateFormatter.date(from: "210107"), url: "210107_Jhana_Practice.mp3"),
                TalkData(id: "3", title: "What the Buddha Taught", date: DateFormatter.ymdDateFormatter.date(from: "210108"), url: "210108_What_the_Buddha_Taught.mp3")
            ]
            return talkDataList
        case .multipleMonths:
            let talkDataList = [
                TalkData(id: "1", title: "A Radiant Practice", date: DateFormatter.ymdDateFormatter.date(from: "210101"), url: "210101_A_Radiant_Practice.mp3"),
                TalkData(id: "2", title: "Going Out of Your Way", date: DateFormatter.ymdDateFormatter.date(from: "210107"), url: "210107_Going_Out_of_Your_Way.mp3"),
                
                TalkData(id: "3", title: "Your Borrowed Goods", date: DateFormatter.ymdDateFormatter.date(from: "210412"), url: "210412_Your_Borrowed_Goods.mp3"),
                TalkData(id: "4", title: "Brahmaviharas at the Breath", date: DateFormatter.ymdDateFormatter.date(from: "210413"), url: "210413_Brahmaviharas_at_the_Breath.mp3"),
                TalkData(id: "5", title: "For a Routine That Isn't Routine", date: DateFormatter.ymdDateFormatter.date(from: "210414"), url: "210414_For_a_Routine_That_Isn't_Routine.mp3"),
                TalkData(id: "6", title: "On the Surface of Things", date: DateFormatter.ymdDateFormatter.date(from: "210416"), url: "210416_On_the_Surface_of_Things.mp3"),
                TalkData(id: "7", title: "Virtue, Concentration, Discernment", date: DateFormatter.ymdDateFormatter.date(from: "210417"), url: "210417_Virtue,_Concentration,_Discernment.mp3"),
                
                TalkData(id: "8", title: "Your Ancestral Territory", date: DateFormatter.ymdDateFormatter.date(from: "211018"), url: "211018_Your_Ancestral_Territory.mp3"),
                TalkData(id: "9", title: "Fix Your Views", date: DateFormatter.ymdDateFormatter.date(from: "211027"), url: "211027_Fix_Your_Views.mp3"),
                TalkData(id: "10", title: "Joyous Endurance", date: DateFormatter.ymdDateFormatter.date(from: "211029"), url: "211029_Joyous_Endurance.mp3")
            ]
            return talkDataList
        }
    }
}
