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
        let result = sut.parse(fileName: "kajdflkjad", talkCategory: .evening, year: 2021)
        XCTAssertNil(result)
    }
    
    func testValidYMDFileName() throws {
        let sut = AudioFileNameParser()
        let result = sut.parse(fileName: "211103_A_Radiant_Practice.mp3", talkCategory: .evening, year: 2021)
        XCTAssertEqual(result?.title, "A Radiant Practice")
        XCTAssertEqual(result?.url,  "https://www.dhammatalks.org/Archive/y2021/211103_A_Radiant_Practice.mp3")
        XCTAssertEqual(2021, Calendar.current.component(.year, from: result!.date!))
        XCTAssertEqual(11, Calendar.current.component(.month, from: result!.date!))
        XCTAssertEqual(3, Calendar.current.component(.day, from: result!.date!))
    }
    
    func testValidYMFileName() {
        let sut = AudioFileNameParser()
        let result = sut.parse(fileName: "0112n1a1%20Encouragement.mp3", talkCategory: .evening, year: 2001)
        
        XCTAssertEqual(result?.title, "Encouragement")
        XCTAssertEqual(result?.url,  "https://www.dhammatalks.org/Archive/y2001/0112n1a1%20Encouragement.mp3")
        XCTAssertEqual(2001, Calendar.current.component(.year, from: result!.date!))
        XCTAssertEqual(12, Calendar.current.component(.month, from: result!.date!))
    }
    
    func testQuestionMark() {
        let sut = AudioFileNameParser()
        let result = sut.parse(fileName: "210629_Why_Limit_YourselfQ.mp3", talkCategory: .evening, year: 2021)
        XCTAssertEqual(result?.title, "Why Limit Yourself?")
        XCTAssertEqual(result?.url,  "https://www.dhammatalks.org/Archive/y2021/210629_Why_Limit_YourselfQ.mp3")
        XCTAssertEqual(2021, Calendar.current.component(.year, from: result!.date!))
        XCTAssertEqual(6, Calendar.current.component(.month, from: result!.date!))
        XCTAssertEqual(29, Calendar.current.component(.day, from: result!.date!))
    }
    
    func testUnderscoreQuestionMark() {
        let sut = AudioFileNameParser()
        let result = sut.parse(fileName: "180509_Where_Are_You_Going_Q.mp3", talkCategory: .evening, year: 2018)
        XCTAssertEqual(result?.title, "Where Are You Going?")
        XCTAssertEqual(result?.url,  "https://www.dhammatalks.org/Archive/y2018/180509_Where_Are_You_Going_Q.mp3")
        XCTAssertEqual(2018, Calendar.current.component(.year, from: result!.date!))
        XCTAssertEqual(5, Calendar.current.component(.month, from: result!.date!))
        XCTAssertEqual(9, Calendar.current.component(.day, from: result!.date!))
    }
}
