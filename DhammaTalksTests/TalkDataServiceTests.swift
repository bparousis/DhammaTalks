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

    func testError() async {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .error))
        let talkSections = await sut.fetchEveningTalksForYear(2021)
        XCTAssertEqual(talkSections.count, 0)
    }
    
    func testNoTalks() async {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .noTalks))
        let talkSections = await sut.fetchEveningTalksForYear(2021)
        XCTAssertEqual(talkSections.count, 0)
    }
    
    func testOneMonthWithTalks() async {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .oneMonth))
        let talkSections = await sut.fetchEveningTalksForYear(2021)
        XCTAssertEqual(talkSections.count, 1)
        XCTAssertEqual(talkSections[0].talks.count, 3)
    }
    
    func testMultipleMonthsWithTalks() async {
        let sut = TalkDataService(htmlPageFetcher: MockHTMLPageFetcher(testCase: .multipleMonths))
        let talkSections = await sut.fetchEveningTalksForYear(2021)
        XCTAssertEqual(talkSections.count, 4)
        XCTAssertEqual(talkSections[0].talks.count, 1)
        XCTAssertEqual(talkSections[1].talks.count, 3)
        XCTAssertEqual(talkSections[2].talks.count, 6)
        XCTAssertEqual(talkSections[3].talks.count, 2)
    }
}

class MockHTMLPageFetcher: HTMLPageFetcher {
    private let testCase: TestCase
    
    init(testCase: TestCase) {
        self.testCase = testCase
    }
    
    enum TestCase {
        case error
        case noTalks
        case oneMonth
        case multipleMonths
    }

    override func getHTMLForCategory(_ category: TalkCategory) async -> Result<HTMLData,HTMLPageFetcherError> {
        switch testCase {
        case .error:
            return .failure(.failedToRetrieve)
        case .noTalks:
            let html = """
            <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
            <html>
             <head>
              <title>Index of /Archive/y2021</title>
             </head>
             <body>
            <h1>Index of /Archive/y2021</h1>
              <table>
               <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th><th><a href="?C=N;O=D">Name</a></th><th><a href="?C=M;O=A">Last modified</a></th><th><a href="?C=S;O=A">Size</a></th><th><a href="?C=D;O=A">Description</a></th></tr>
               <tr><th colspan="5"><hr></th></tr>
            <tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td><td><a href="/Archive/">Parent Directory</a></td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_a">test_a</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_b">test_b</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
               <tr><th colspan="5"><hr></th></tr>
            </table>
            <address>Apache/2.4.48 (Debian) Server at www.dhammatalks.org Port 443</address>
            </body></html>
            """
            return .success(HTMLData(html: html, talkCategory: category))
            
        case .oneMonth:
            let html = """
            <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
            <html>
             <head>
              <title>Index of /Archive/y2021</title>
             </head>
             <body>
            <h1>Index of /Archive/y2021</h1>
              <table>
               <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th><th><a href="?C=N;O=D">Name</a></th><th><a href="?C=M;O=A">Last modified</a></th><th><a href="?C=S;O=A">Size</a></th><th><a href="?C=D;O=A">Description</a></th></tr>
               <tr><th colspan="5"><hr></th></tr>
            <tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td><td><a href="/Archive/">Parent Directory</a></td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210101_A_Radiant_Practice.mp3">210101_A_Radiant_Practice.mp3</a></td><td align="right">2021-01-07 03:12  </td><td align="right">6.5M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210107_Going_Out_of_Your_Way.mp3">210107_Going_Out_of_Your_Way.mp3</a></td><td align="right">2021-01-12 02:52  </td><td align="right">5.6M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210108_To_Be_Worthy_of_the_Dhamma.mp3">210108_To_Be_Worthy_of_the_Dhamma.mp3</a></td><td align="right">2021-01-12 02:52  </td><td align="right">6.6M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="all_2021_01.zip">all_2021_01.zip</a></td><td align="right">2021-02-02 05:50  </td><td align="right">229M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="all_2021_02.zip">all_2021_02.zip</a></td><td align="right">2021-04-18 03:06  </td><td align="right">179M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_a">test_a</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_b">test_b</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
               <tr><th colspan="5"><hr></th></tr>
            </table>
            <address>Apache/2.4.48 (Debian) Server at www.dhammatalks.org Port 443</address>
            </body></html>
            """
            return .success(HTMLData(html: html, talkCategory: category))
        case .multipleMonths:
            let html = """
            <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
            <html>
             <head>
              <title>Index of /Archive/y2021</title>
             </head>
             <body>
            <h1>Index of /Archive/y2021</h1>
              <table>
               <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th><th><a href="?C=N;O=D">Name</a></th><th><a href="?C=M;O=A">Last modified</a></th><th><a href="?C=S;O=A">Size</a></th><th><a href="?C=D;O=A">Description</a></th></tr>
               <tr><th colspan="5"><hr></th></tr>
            <tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td><td><a href="/Archive/">Parent Directory</a></td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210101_A_Radiant_Practice.mp3">210101_A_Radiant_Practice.mp3</a></td><td align="right">2021-01-07 03:12  </td><td align="right">6.5M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210108_To_Be_Worthy_of_the_Dhamma.mp3">210108_To_Be_Worthy_of_the_Dhamma.mp3</a></td><td align="right">2021-01-12 02:52  </td><td align="right">6.6M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="all_2021_01.zip">all_2021_01.zip</a></td><td align="right">2021-02-02 05:50  </td><td align="right">229M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="all_2021_02.zip">all_2021_02.zip</a></td><td align="right">2021-04-18 03:06  </td><td align="right">179M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210412_Borrowed_Goods.mp3">210412_Borrowed_Goods.mp3</a></td><td align="right">2021-04-18 02:44  </td><td align="right">5.4M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210413_Brahmaviharas_at_the_Breath.mp3">210413_Brahmaviharas_at_the_Breath.mp3</a></td><td align="right">2021-04-18 02:45  </td><td align="right">6.7M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210414_For_a_Routine_That_Isn't_Routine.mp3">210414_For_a_Routine_That_Isn't_Routine.mp3</a></td><td align="right">2021-04-18 02:45  </td><td align="right">7.4M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210416_On_the_Surface_of_Things.mp3">210416_On_the_Surface_of_Things.mp3</a></td><td align="right">2021-04-21 05:47  </td><td align="right"> 11M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210417_Virtue,_Concentration,_Discernment.mp3">210417_Virtue,_Concentration,_Discernment.mp3</a></td><td align="right">2021-04-21 05:47  </td><td align="right"> 11M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="210418_Your_Ancestral_Territory.mp3">210418_Your_Ancestral_Territory.mp3</a></td><td align="right">2021-04-21 05:48  </td><td align="right"> 10M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="211027_Fix_Your_Views.mp3">211027_Fix_Your_Views.mp3</a></td><td align="right">2021-10-30 03:48  </td><td align="right">6.7M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="211029_Joyous_Endurance.mp3">211029_Joyous_Endurance.mp3</a></td><td align="right">2021-11-01 19:14  </td><td align="right">6.4M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="211031_With_This_Body,_This_Mind.mp3">211031_With_This_Body,_This_Mind.mp3</a></td><td align="right">2021-11-01 19:14  </td><td align="right">6.2M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/sound2.gif" alt="[SND]"></td><td><a href="211101_No-Tech_Meditation.mp3">211101_No-Tech_Meditation.mp3</a></td><td align="right">2021-11-05 04:30  </td><td align="right">5.9M</td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_a">test_a</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
            <tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="test_b">test_b</a></td><td align="right">2021-03-09 00:38  </td><td align="right">  0 </td><td>&nbsp;</td></tr>
               <tr><th colspan="5"><hr></th></tr>
            </table>
            <address>Apache/2.4.48 (Debian) Server at www.dhammatalks.org Port 443</address>
            </body></html>
            """
            return .success(HTMLData(html: html, talkCategory: category))
        }
    }
}
