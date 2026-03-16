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
    
    func testNoTalks() async throws {
        let sut = TalkDataService(talkFetcher: MockTalkFetcher(testCase: .noTalks))
        let result = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        XCTAssertEqual(result.count, 0)
    }

    func testOneMonthWithTalksWithSearch() async throws {
        let sut = TalkDataService(talkFetcher: MockTalkFetcher(testCase: .oneMonth))
        var talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021))
        XCTAssertEqual(talkDataList.count, 3)

        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "practice"))
        XCTAssertEqual(talkDataList.count, 1)
        
        talkDataList = try await sut.fetchYearlyTalks(query: DailyTalkQuery(category: .evening, year: 2021, searchText: "car"))
        XCTAssertEqual(talkDataList.count, 0)
    }

    func testMultipleMonthsWithTalksWithSearch() async throws {
        let sut = TalkDataService(talkFetcher: MockTalkFetcher(testCase: .multipleMonths))
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
        XCTAssertEqual(talkSeriesList.count, 11)
        XCTAssertEqual(talkSeriesList[0].sections.count, 1)
        XCTAssertEqual(talkSeriesList[0].sections[0].talks.count, 50)
        XCTAssertEqual(talkSeriesList[8].sections.count, 7)
    }
}
