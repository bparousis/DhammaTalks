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
        let result = AudioFileNameParser.extractTitleAndFilename("kajdflkjad")
        XCTAssertNil(result)
    }
    
    func testMP3WithoutDateInfo() throws {
        let result = AudioFileNameParser.extractDate("something.mp3")
        XCTAssertNil(result)
    }
    
    func testValidYMDFileName() throws {
        let result = AudioFileNameParser.extractTitleAndFilename("211103_A_Radiant_Practice.mp3")
        XCTAssertEqual(result?.title, "A Radiant Practice")
        XCTAssertEqual(result?.filename, "211103_A_Radiant_Practice.mp3")
        
        let date = try XCTUnwrap(AudioFileNameParser.extractDate("211103_A_Radiant_Practice.mp3"))
        
        XCTAssertEqual(2021, Calendar.current.component(.year, from: date))
        XCTAssertEqual(11, Calendar.current.component(.month, from: date))
        XCTAssertEqual(3, Calendar.current.component(.day, from: date))
    }
    
    func testValidYMFileName() throws {
        let result = AudioFileNameParser.extractTitleAndFilename("0112n1a1%20Encouragement.mp3")
        let date = try XCTUnwrap(AudioFileNameParser.extractDate("0112n1a1%20Encouragement.mp3"))
        XCTAssertEqual(result?.title, "Encouragement")
        XCTAssertEqual(2001, Calendar.current.component(.year, from: date))
        XCTAssertEqual(12, Calendar.current.component(.month, from: date))
    }
    
    func testQuestionMark() throws {
        let result = AudioFileNameParser.extractTitleAndFilename("210629_Why_Limit_YourselfQ.mp3")
        XCTAssertEqual(result?.title, "Why Limit Yourself?")

        let date = try XCTUnwrap(AudioFileNameParser.extractDate("210629_Why_Limit_YourselfQ.mp3"))
        XCTAssertEqual(2021, Calendar.current.component(.year, from: date))
        XCTAssertEqual(6, Calendar.current.component(.month, from: date))
        XCTAssertEqual(29, Calendar.current.component(.day, from: date))
    }
    
    func testUnderscoreQuestionMark() throws {
        let result = AudioFileNameParser.extractTitleAndFilename("180509_Where_Are_You_Going_Q.mp3")
        XCTAssertEqual(result?.title, "Where Are You Going?")
        
        let date = try XCTUnwrap(AudioFileNameParser.extractDate("180509_Where_Are_You_Going_Q.mp3"))
        XCTAssertEqual(2018, Calendar.current.component(.year, from: date))
        XCTAssertEqual(5, Calendar.current.component(.month, from: date))
        XCTAssertEqual(9, Calendar.current.component(.day, from: date))
    }
    
    func testWithSlashse() throws {
        let result = AudioFileNameParser.extractTitleAndFilename("/Archive/y2023/230129_The_Projector.mp3")
        XCTAssertEqual(result?.title, "The Projector")
        XCTAssertEqual(result?.filename, "230129_The_Projector.mp3")
        let date = try XCTUnwrap(AudioFileNameParser.extractDate("/Archive/y2023/230129_The_Projector.mp3"))
        XCTAssertEqual(2023, Calendar.current.component(.year, from: date))
        XCTAssertEqual(1, Calendar.current.component(.month, from: date))
        XCTAssertEqual(29, Calendar.current.component(.day, from: date))
    }
}
