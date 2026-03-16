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
                                     downloadManager: DownloadManager(),
                                     playlistService: PlaylistService(managedObjectContext: context))
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
