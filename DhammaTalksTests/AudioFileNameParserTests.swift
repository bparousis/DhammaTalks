//
//  AudioFileNameParserTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import XCTest
@testable import DhammaTalks

class AudioFileNameParserTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInvalidFileName() throws {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("kajdflkjad")
        XCTAssertNil(result)
    }
    
    func testMP3WithoutDateInfo() throws {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("something.mp3")
        XCTAssertNil(result)
    }
    
    func testValidYMDFileName() throws {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("211103_A_Radiant_Practice.mp3")
        XCTAssertEqual(result?.title, "A Radiant Practice")
        XCTAssertEqual(2021, Calendar.current.component(.year, from: result!.date))
        XCTAssertEqual(11, Calendar.current.component(.month, from: result!.date))
        XCTAssertEqual(3, Calendar.current.component(.day, from: result!.date))
    }
    
    func testValidYMFileName() {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("0112n1a1%20Encouragement.mp3")
        
        XCTAssertEqual(result?.title, "Encouragement")
        XCTAssertEqual(2001, Calendar.current.component(.year, from: result!.date))
        XCTAssertEqual(12, Calendar.current.component(.month, from: result!.date))
    }
    
    func testQuestionMark() {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("210629_Why_Limit_YourselfQ.mp3")
        XCTAssertEqual(result?.title, "Why Limit Yourself?")
        XCTAssertEqual(2021, Calendar.current.component(.year, from: result!.date))
        XCTAssertEqual(6, Calendar.current.component(.month, from: result!.date))
        XCTAssertEqual(29, Calendar.current.component(.day, from: result!.date))
    }
    
    func testUnderscoreQuestionMark() {
        let sut = AudioFileNameParser()
        let result = sut.parseFileNameWithDate("180509_Where_Are_You_Going_Q.mp3")
        XCTAssertEqual(result?.title, "Where Are You Going?")
        XCTAssertEqual(2018, Calendar.current.component(.year, from: result!.date))
        XCTAssertEqual(5, Calendar.current.component(.month, from: result!.date))
        XCTAssertEqual(9, Calendar.current.component(.day, from: result!.date))
    }
}
