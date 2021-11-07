//
//  TalkDataExtractorTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-11-07.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import XCTest
@testable import DhammaTalks

class TalkDataExtractorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExtractingTalkData() {
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
        
        let extractor = TalkDataExtractor()
        let results = extractor.extractFromHTML(html)
        XCTAssertEqual(results.count, 3)
    }
    
    func testExtractingFromPageWithNoTalkData() {
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
        
        let extractor = TalkDataExtractor()
        let results = extractor.extractFromHTML(html)
        XCTAssertEqual(results.count, 0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
