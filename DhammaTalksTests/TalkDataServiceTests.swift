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
        let result = await sut.fetchYearlyTalks(category: .evening, year: 2021)
        switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                XCTAssertEqual(error as! HTMLPageFetcher.HTMLPageFetcherError, HTMLPageFetcher.HTMLPageFetcherError.failedToRetrieve)
        }
    }
    
    func testNoTalks() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .noTalks))
        let result = await sut.fetchYearlyTalks(category: .evening, year: 2021)
        let count = try result.get().count
        XCTAssertEqual(count, 0)
    }
    
    func testOneMonthWithTalks() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .oneMonth))
        let result = await sut.fetchYearlyTalks(category: .evening, year: 2021)
        let talkSections = try result.get()
        XCTAssertEqual(talkSections.count, 1)
        XCTAssertEqual(talkSections[0].talks.count, 3)
    }
    
    func testMultipleMonthsWithTalks() async throws {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .multipleMonths))
        let result = await sut.fetchYearlyTalks(category: .evening, year: 2021)
        let talkSections = try result.get()
        XCTAssertEqual(talkSections.count, 3)
        XCTAssertEqual(talkSections[0].talks.count, 2)
        XCTAssertEqual(talkSections[1].talks.count, 5)
        XCTAssertEqual(talkSections[2].talks.count, 3)
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

    override func getYearlyHTMLForCategory(_ category: DailyTalkCategory, year: Int) async -> Result<YearlyTalkData, Error> {
        switch testCase {
        case .error:
            return .failure(HTMLPageFetcherError.failedToRetrieve)
        case .noTalks:
            return .success(YearlyTalkData(talkDataList: [], talkCategory: category, year: year))
        case .oneMonth:
            
            let talkDataList = [
                TalkData(id: "1", title: "Title 1", date: DateFormatter.ymdDateFormatter.date(from: "210101"), url: "210101_A_Radiant_Practice.mp3"),
                TalkData(id: "2", title: "Title 2", date: DateFormatter.ymdDateFormatter.date(from: "210107"), url: "210107_Going_Out_of_Your_Way.mp3"),
                TalkData(id: "3", title: "Title 3", date: DateFormatter.ymdDateFormatter.date(from: "210108"), url: "210108_To_Be_Worthy_of_the_Dhamma.mp3")
            ]
            return .success(YearlyTalkData(talkDataList: talkDataList, talkCategory: category, year: year))
        case .multipleMonths:
            let talkDataList = [
                TalkData(id: "1", title: "Title 1", date: DateFormatter.ymdDateFormatter.date(from: "210101"), url: "210101_A_Radiant_Practice.mp3"),
                TalkData(id: "2", title: "Title 2", date: DateFormatter.ymdDateFormatter.date(from: "210107"), url: "210107_Going_Out_of_Your_Way.mp3"),
                TalkData(id: "3", title: "Title 3", date: DateFormatter.ymdDateFormatter.date(from: "210412"), url: "210412_Borrowed_Goods.mp3"),
                TalkData(id: "4", title: "Title 4", date: DateFormatter.ymdDateFormatter.date(from: "210413"), url: "210413_Brahmaviharas_at_the_Breath.mp3"),
                TalkData(id: "5", title: "Title 5", date: DateFormatter.ymdDateFormatter.date(from: "210414"), url: "210414_For_a_Routine_That_Isn't_Routine.mp3"),
                TalkData(id: "6", title: "Title 6", date: DateFormatter.ymdDateFormatter.date(from: "210416"), url: "210416_On_the_Surface_of_Things.mp3"),
                TalkData(id: "7", title: "Title 7", date: DateFormatter.ymdDateFormatter.date(from: "210417"), url: "210417_Virtue,_Concentration,_Discernment.mp3"),
                TalkData(id: "8", title: "Title 8", date: DateFormatter.ymdDateFormatter.date(from: "211018"), url: "211018_Your_Ancestral_Territory.mp3"),
                TalkData(id: "9", title: "Title 9", date: DateFormatter.ymdDateFormatter.date(from: "211027"), url: "211027_Fix_Your_Views.mp3"),
                TalkData(id: "10", title: "Title 10", date: DateFormatter.ymdDateFormatter.date(from: "211029"), url: "211029_Joyous_Endurance.mp3")
            ]
            return .success(YearlyTalkData(talkDataList: talkDataList, talkCategory: category, year: year))
        }
    }
}
