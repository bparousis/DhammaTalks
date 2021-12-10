//
//  HTMLPageFetcherTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation
import XCTest
@testable import DhammaTalks

class HTMLPageFetcherTests: XCTestCase {
    
    private static let htmlContent = """
            <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
            <html>
            <body>
            <h1>Header</h1>
            <p>Paragraph</p>
            </body>
            </html>
            """
    
    private var sut: HTMLPageFetcher!

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = {request in
            let exampleData = Self.htmlContent.data(using: .utf8)!
            let response = HTTPURLResponse.init(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, exampleData)
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        sut = HTMLPageFetcher(urlSession: urlSession)
    }

    override func tearDownWithError() throws {
        MockURLProtocol.reset()
    }
    
    func testNonCachedRequest() async {
        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        let currentYear = Calendar.current.component(.year, from: Date())
        var result = await sut.getYearlyHTMLForCategory(.evening, year: currentYear)
        switch result {
        case .success(let htmlData):
            XCTAssertTrue(MockURLProtocol.requestURLHistory.contains("https://www.dhammatalks.org/Archive/y2021"))
            XCTAssertEqual(htmlData.html, Self.htmlContent)
            XCTAssertEqual(htmlData.year, currentYear)
            XCTAssertEqual(htmlData.talkCategory, .evening)
        case .failure:
            XCTFail("Request should have succeeded.")
        }
        
        result = await sut.getYearlyHTMLForCategory(.short, year: currentYear)
        switch result {
        case .success(let htmlData):
            XCTAssertTrue(MockURLProtocol.requestURLHistory.contains("https://www.dhammatalks.org/Archive/shorttalks/y2021"))
            XCTAssertEqual(htmlData.html, Self.htmlContent)
            XCTAssertEqual(htmlData.year, currentYear)
            XCTAssertEqual(htmlData.talkCategory, .short)
        case .failure:
            XCTFail("Request should have succeeded.")
        }
    }
    
    func testCachedRequest() async {
        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        var result = await sut.getYearlyHTMLForCategory(.evening, year: 2000)
        switch result {
        case .success(let htmlData):
            // Check to see that we didn't go over the net to get this data.
            XCTAssertFalse(MockURLProtocol.requestURLHistory.contains("https://www.dhammatalks.org/Archive/y2020"))
            XCTAssertEqual(htmlData.html, try! String(contentsOf: Bundle.main.url(forResource: "y2000", withExtension: "html")!))
            XCTAssertEqual(htmlData.year, 2000)
            XCTAssertEqual(htmlData.talkCategory, .evening)
        case .failure:
            XCTFail("Request should have succeeded.")
        }

        result = await sut.getYearlyHTMLForCategory(.short, year: 2010)
        switch result {
        case .success(let htmlData):
            // Check to see that we didn't go over the net to get this data.
            XCTAssertFalse(MockURLProtocol.requestURLHistory.contains("https://www.dhammatalks.org/Archive/shorttalks/y2020"))
            XCTAssertEqual(htmlData.html, try! String(contentsOf: Bundle.main.url(forResource: "short_y2010", withExtension: "html")!))
            XCTAssertEqual(htmlData.year, 2010)
            XCTAssertEqual(htmlData.talkCategory, .short)
        case .failure:
            XCTFail("Request should have succeeded.")
        }
    }
    
    func testFailedRequest() async {
        MockURLProtocol.failWithRequest = "https://www.dhammatalks.org/Archive/shorttalks/y2008"
        let result = await sut.getYearlyHTMLForCategory(.short, year: 2008)
        switch result {
        case .success(_):
            XCTFail("Request should have failed.")
        case .failure(let error):
            XCTAssertNotNil(error)
        }
    }
}
