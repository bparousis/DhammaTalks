//
//  DailyTalkCategoryTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import XCTest
@testable import DhammaTalks

class DailyTalkCategoryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTalkURLForYear() {
        let eveningTalkURL = DailyTalkCategory.evening.talkURLForYear(2000)
        XCTAssertEqual(eveningTalkURL, "https://www.dhammatalks.org/Archive/y2000")
        
        let shortTalkURL = DailyTalkCategory.short.talkURLForYear(2000)
        XCTAssertEqual(shortTalkURL, "https://www.dhammatalks.org/Archive/shorttalks/y2000")
    }
    
    func testCachedFileNameForYear() {
        let eveningCachedFileName = DailyTalkCategory.evening.cachedFileNameForYear(2020)
        XCTAssertEqual(eveningCachedFileName, "y2020")
        
        let shortCachedFileName = DailyTalkCategory.short.cachedFileNameForYear(2020)
        XCTAssertEqual(shortCachedFileName, "short_y2020")
    }
    
    func testTitle() {
        XCTAssertEqual(DailyTalkCategory.evening.title, "Evening")
        XCTAssertEqual(DailyTalkCategory.short.title, "Short")
    }
    
    func testStartYear() {
        XCTAssertEqual(DailyTalkCategory.evening.startYear, 2000)
        XCTAssertEqual(DailyTalkCategory.short.startYear, 2010)
    }
}
