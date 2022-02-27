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
        Current = .mock
        let context = TestCoreDataStack().persistentContainer.viewContext
        talkDataService = MockTalkDataService()
        sut = DailyTalkListViewModel(talkDataService: talkDataService,
                                     talkUserInfoService: TalkUserInfoService(managedObjectContext: context),
                                     downloadManager: DownloadManager())
    }

    override func tearDownWithError() throws {
    }
    
    func testFetchOneMonth() async {
        talkDataService.testCase = .oneMonth
        XCTAssertTrue(sut.talkSections.isEmpty)
        if case .initial = sut.state {} else {
            XCTFail("Expected state to be initial.")
        }
        await sut.fetchData()
        if case .loaded = sut.state {} else {
            XCTFail("Expected state to be loaded.")
        }
        XCTAssertEqual(sut.talkSections.count, 1)
        XCTAssertEqual(sut.talkSections[0].talkRows.count, 3)
    }
    
    func testFetchMultipleMonths() async {
        talkDataService.testCase = .multipleMonths
        XCTAssertTrue(sut.talkSections.isEmpty)
        if case .initial = sut.state {} else {
            XCTFail("Expected state to be initial.")
        }
        await sut.fetchData()
        if case .loaded = sut.state {} else {
            XCTFail("Expected state to be loaded.")
        }
        XCTAssertEqual(sut.talkSections.count, 3)

        XCTAssertEqual(sut.talkSections[0].talkRows.count, 2)
        XCTAssertEqual(sut.talkSections[1].talkRows.count, 5)
        XCTAssertEqual(sut.talkSections[2].talkRows.count, 3)
    }
    
    func testFailedFetchData() async {
        talkDataService.testCase = .fail
        XCTAssertTrue(sut.talkSections.isEmpty)
        if case .initial = sut.state {} else {
            XCTFail("Expected state to be initial.")
        }
        await sut.fetchData()
        
        if case .error = sut.state {} else {
            XCTFail("Expected state to be error.")
        }
        
        XCTAssertTrue(sut.showingAlert)
        
        XCTAssertTrue(sut.talkSections.isEmpty)
    }
    
    func testCanceledRequestWithFetchData() async {
        talkDataService.testCase = .cancel
        XCTAssertTrue(sut.talkSections.isEmpty)
        if case .initial = sut.state {} else {
            XCTFail("Expected state to be initial.")
        }
        await sut.fetchData()
        XCTAssertFalse(sut.showingAlert)
        // If a request gets canceled it's due to a rapid request canceling the previous one.
        // So we still want it to be in a loading state in this scenario, since the second
        // request is loading.
        if case .loading = sut.state {} else {
            XCTFail("Expected state to be loading.")
        }
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
    
    func testAppSettings() {
        XCTAssertNil(AppSettings.selectedTalkYear)
        XCTAssertNil(AppSettings.selectedTalkCategory)
        sut.selectedYear = 2000
        sut.selectedCategory = .evening
        XCTAssertEqual(AppSettings.selectedTalkYear, 2000)
        XCTAssertEqual(AppSettings.selectedTalkCategory, .evening)
        sut.selectedCategory = .short
        XCTAssertEqual(AppSettings.selectedTalkYear, 2010)
        XCTAssertEqual(AppSettings.selectedTalkCategory, .short)
    }
    
    func testYears() {
        XCTAssertEqual(sut.years, (2000...sut.currentYear).reversed())
        sut.selectedCategory = .short
        XCTAssertEqual(sut.years, (2010...sut.currentYear).reversed())
        sut.selectedCategory = .evening
        XCTAssertEqual(sut.years, (2000...sut.currentYear).reversed())
    }
    
    func testWhenRefreshable() {
        sut.selectedYear = sut.currentYear
        XCTAssertTrue(sut.isRefreshable)
    }
    
    func testWhenNotRefreshable() {
        sut.selectedYear = 2021
        XCTAssertFalse(sut.isRefreshable)
    }
}


private class MockTalkDataService: TalkDataService {
    
    var testCase: TestCase!

    enum TestCase {
        case fail
        case cancel
        case oneMonth
        case multipleMonths
    }

    override func fetchYearlyTalks(query: DailyTalkQuery) async throws -> [TalkData] {
        switch testCase {
        case .fail:
            throw NSError(domain: "test", code: 100, userInfo: nil)
        case .cancel:
            throw NSError(domain: "test", code: URLError.cancelled.rawValue, userInfo: nil)
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
        case .none:
            return []
        }
    }
}
