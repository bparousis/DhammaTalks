//
//  DhammaTalkAPITests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import XCTest
@testable import DhammaTalks

class DhammaTalkAPITests: XCTestCase {
    
    private var sut: DhammaTalkAPI!
    private var isValid = true

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { [unowned self] request in
            let data = self.isValid ? JSONTestData.validJSONContent.data(using: .utf8)! :
                                      JSONTestData.invalidJSONContent.data(using: .utf8)!
            let response = HTTPURLResponse.init(url: request.url!,
                                                statusCode: 200,
                                                httpVersion: "2.0",
                                                headerFields: nil)!
            return (response, data)
        }
    }

    override func tearDownWithError() throws {
        MockURLProtocol.reset()
    }
    
    func testSuccessfulRequest() async throws {
        isValid = true

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        let fileStorage = MockFileStorage()
        sut = DhammaTalkAPI(urlSession: urlSession, fileStorage: fileStorage)

        XCTAssertFalse(fileStorage.didSaveData)
        let talkDataList = try await sut.fetchTalkCollection(for: .evening, year: 2010)
        XCTAssertEqual(talkDataList.count, 5)
        XCTAssertTrue(fileStorage.didSaveData)
    }
    
    func testFailedRequest() async throws {
        isValid = false
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        let fileStorage = MockFileStorage()
        sut = DhammaTalkAPI(urlSession: urlSession, fileStorage: fileStorage)

        let expectation = expectation(description: "Throws error")        
        do {
            _ = try await sut.fetchTalkCollection(for: .evening, year: 2010)
        } catch {
            if let fetchError = error as? TalkFetchError {
                switch fetchError {
                case .error:
                    expectation.fulfill()
                case .belowMinimumVersion:
                    XCTFail("Expected .error")
                }
            } else {
                XCTFail("Expected TalkFetchError")
            }
        }
        await fulfillment(of: [expectation])
    }
}


private class MockFileStorage: FileStorage {
    
    private let localStorage = LocalFileStorage()
    var saveURL: URL?
    var performedRemoveFilename: String?
    var didSaveData = false
    
    func save(at url: URL, withFilename filename: String) throws {
        saveURL = url
    }
    
    func remove(filename: String) throws {
        performedRemoveFilename = filename
    }
    
    func exists(filename: String) -> Bool {
        return localStorage.exists(filename: filename)
    }
    
    func createURL(for filename: String) -> URL {
        return localStorage.createURL(for: filename)
    }
    
    func saveData(_ data: Data, withFilename filename: String) throws {
        didSaveData = true
    }
}


struct JSONTestData {

    static let invalidJSONContent = "ABCDEFG"
    static let validJSONContent =
    """
            {"statusCode":200,"body":[{"_id":"65082f0490136f3308100003","year":2000,"month":12,"day":31,"streamingLink":"https://www.dhammatalks.org/Archive/y2000/001231 Start the Year Right Here.mp3","talkTitle":"Start the Year Right Here","transcribeLink":"https://www.dhammatalks.org/Archive/Writings/Transcripts/001231_Start_the_year_right_here.pdf","collection":"evening_talks"},{"_id":"65082f0490136f3308100004","year":2000,"month":11,"day":1,"streamingLink":"https://www.dhammatalks.org/Archive/y2000/001101 Unraveling the Present.mp3","talkTitle":"Unraveling the Present","transcribeLink":"https://www.dhammatalks.org/Archive/Writings/Transcripts/001101_Unraveling_the_Present.pdf","collection":"evening_talks"},{"_id":"65082f0490136f3308100005","year":2000,"month":10,"day":15,"streamingLink":"https://www.dhammatalks.org/Archive/y2000/001015 Knowing & Acting.mp3","talkTitle":"Knowing & Acting","transcribeLink":"https://www.dhammatalks.org/Archive/Writings/Transcripts/001015_Knowing_&_Acting.pdf","collection":"evening_talks"},{"_id":"65082f0490136f3308100006","year":2000,"month":10,"day":14,"streamingLink":"https://www.dhammatalks.org/Archive/y2000/001014 Feeding the Mind.mp3","talkTitle":"Feeding the Mind","transcribeLink":"https://www.dhammatalks.org/Archive/Writings/Transcripts/001014_Feeding_the_Mind.pdf","collection":"evening_talks"},{"_id":"65082f0490136f3308100007","year":2000,"month":10,"day":13,"streamingLink":"https://www.dhammatalks.org/Archive/y2000/001013 Warrior Knowledge.mp3","talkTitle":"Warrior Knowledge","transcribeLink":"https://www.dhammatalks.org/books/Meditations2/Section0031.html","collection":"evening_talks"}]}
    """
}
