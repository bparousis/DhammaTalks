//
//  DailyTalkListViewModelTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-20.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

import XCTest
@testable import DhammaTalks

class DailyTalkListViewModelTests: XCTestCase {

    private var sut: DailyTalkListViewModel!
    fileprivate var talkDataService: MockTalkDataService!
    
    override func setUpWithError() throws {
        talkDataService = MockTalkDataService()
        sut = DailyTalkListViewModel(talkDataService: talkDataService)
    }

    override func tearDownWithError() throws {
    }
    
    func testFetchData() async {
        XCTAssertTrue(sut.talkSections.isEmpty)
        XCTAssertFalse(sut.isFetchDataFinished)
        await sut.fetchData()
        XCTAssertTrue(sut.isFetchDataFinished)
        XCTAssertEqual(sut.talkSections.count, 2)
    }
    
    func testFailedFetchData() async {
        talkDataService.shouldFail = true
        XCTAssertTrue(sut.talkSections.isEmpty)
        XCTAssertFalse(sut.isFetchDataFinished)
        await sut.fetchData()
        XCTAssertTrue(sut.showingAlert)
        XCTAssertTrue(sut.isFetchDataFinished)
        XCTAssertTrue(sut.talkSections.isEmpty)
    }
    
    func testCanceledRequestWithFetchData() async {
        talkDataService.shouldCancel = true
        XCTAssertTrue(sut.talkSections.isEmpty)
        XCTAssertFalse(sut.isFetchDataFinished)
        await sut.fetchData()
        XCTAssertFalse(sut.showingAlert)
        XCTAssertTrue(sut.isFetchDataFinished)
        XCTAssertTrue(sut.talkSections.isEmpty)
    }
    
    func testSelectedYearChangeOnSettingSelectedCategory() {
        sut.selectedYear = 2000
        sut.selectedCategory = .evening
        XCTAssertEqual(sut.selectedYear, 2000)
        sut.selectedCategory = .short
        XCTAssertEqual(sut.selectedYear, 2010)
        sut.selectedCategory = .evening
        XCTAssertEqual(sut.selectedYear, 2010)
    }
    
    func testYears() {
        XCTAssertEqual(sut.years, (2000...sut.currentYear).reversed())
        sut.selectedCategory = .short
        XCTAssertEqual(sut.years, (2010...sut.currentYear).reversed())
        sut.selectedCategory = .evening
        XCTAssertEqual(sut.years, (2000...sut.currentYear).reversed())
    }
}


private class MockTalkDataService: TalkDataService {
    var shouldFail = false
    var shouldCancel = false
    override func fetchYearlyTalks(category: DailyTalkCategory, year: Int) async -> Result<[TalkSection], Error> {
        if shouldFail {
            return .failure(NSError(domain: "test", code: 100, userInfo: nil))
        }
        else if shouldCancel {
            return .failure(NSError(domain: "test", code: URLError.cancelled.rawValue, userInfo: nil))
        } else {
            let section1 = TalkSection(title: "Section 1", talks: [TalkData(id: "1", title: "Talk 1", date: nil, url: "http://talk1")])
            let section2 = TalkSection(title: "Section 2", talks: [TalkData(id: "2", title: "Talk 2", date: nil, url: "http://talk2")])
            return .success([section1, section2])
        }
    }
}
