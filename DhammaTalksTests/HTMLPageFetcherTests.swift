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
    
    private var sut: HTMLPageFetcher!
    private var useCurrentPage = true

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { [weak self] request in
            let useCurrentPage = self?.useCurrentPage ?? false
            let exampleData = useCurrentPage ? HTMLTestData.currentPageContent.data(using: .utf8)! :
                                               HTMLTestData.directoryPageContent.data(using: .utf8)!
            let response = HTTPURLResponse.init(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, exampleData)
        }
    }

    override func tearDownWithError() throws {
        MockURLProtocol.reset()
    }
    
    func testEveningNonCachedRequest() async throws {
        useCurrentPage = false

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        sut = HTMLPageFetcher(urlSession: urlSession, fileStorage: MockFileStorage())

        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        let currentYear = Calendar.current.component(.year, from: Date())
        let talkDataList = try await sut.getYearlyHTMLForCategory(.evening, year: currentYear)
        XCTAssertEqual(talkDataList.count, 12)
    }

    func testShortNonCachedRequest() async throws {
        useCurrentPage = false
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        sut = HTMLPageFetcher(urlSession: urlSession, fileStorage: MockFileStorage())

        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        let currentYear = Calendar.current.component(.year, from: Date())
        let talkDataList = try await sut.getYearlyHTMLForCategory(.short, year: currentYear)
        XCTAssertEqual(talkDataList.count, 12)
    }
    
    func testCurrentEveningNonCachedRequest() async throws {
        useCurrentPage = true

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        sut = HTMLPageFetcher(urlSession: urlSession, fileStorage: MockFileStorage())

        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        let currentYear = Calendar.current.component(.year, from: Date())
        let talkDataList = try await sut.getYearlyHTMLForCategory(.evening, year: currentYear)
        XCTAssertEqual(talkDataList.count, 28)
    }

    func testEveningCachedRequest() async throws {
        sut = HTMLPageFetcher(fileStorage: MockFileStorage())

        // The current year shouldn't be a cached request and should make a network request to get the latest info.
        let talkDataList = try await sut.getYearlyHTMLForCategory(.evening, year: 2000)
        XCTAssertEqual(talkDataList.count, 5)
    }

    func testShortCachedRequest() async throws {
        sut = HTMLPageFetcher(fileStorage: MockFileStorage())
        let talkDataList = try await sut.getYearlyHTMLForCategory(.short, year: 2010)
        XCTAssertEqual(talkDataList.count, 39)
    }
}


private class MockFileStorage: FileStorage {
    
    private let localStorage = LocalFileStorage()
    var saveURL: URL?
    var performedRemoveFilename: String?
    
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
    }
}


struct HTMLTestData {
    
    static let directoryPageContent =  """
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
    
    static let currentPageContent =
    """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>Current evening talks | dhammatalks.org</title>
        <meta name="description" content="This is the current year archive of audio files of evening Dhamma talks by Thanissaro Bhikkhu given at Metta Forest Monastery.">
          <meta name="dhammatalks.org" content="" />
      <meta name="robots" content="index,follow" />
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <meta property="og:image" content="/images/fb-logo.png" />
      <meta property="og:image:width" content="1200" />
      <meta property="og:image:height" content="630" />
      
        <link rel="shortcut icon" href="/images/favicon.ico" type="image/x-icon" />

      <!--<link rel="stylesheet" href="/css/style.css" type="text/css" />-->
      <link rel="stylesheet" href="/css/style-min.css" type="text/css" />
      <link rel="stylesheet" href="/css/print-min.css" type="text/css" media="print" />
      <link rel="stylesheet" href="/css/quick_links.css" type="text/css" />

    <!--jquery-->
      <script src="/js/jquery.min.js"></script>

    <!--hotkeys-->
      <script src="/js/hotkeys.min.js"></script>
      <!--<script type="text/javascript" src="/js/jquery-3.2.0.min.js"></script>-->

    <!--sutta data for search-->
      <script defer src="/js/quick_links.js"></script>

    <!--slicknav-->
      <script type="text/javascript" src="/js/jquery.slicknav.min.js"></script>

    <!--this is the call for the new slicknav mobile menu-->
      <script>
      $(function(){
            $('#nav-wrapper').slicknav({
                    prependTo: "div#container",
                    label: '',
                    duration:180,
                    easingOpen: "swing",
                    easingClose: "swing"
                });
              });
      </script>

    <!--this loads the monospace font from google fonts-->
    <link href="https://fonts.googleapis.com/css?family=Droid+Sans+Mono" rel="stylesheet">
    <!-- Google Analytics -->
    <script>
      window.ga=window.ga||function(){(ga.q=ga.q||[]).push(arguments)};ga.l=+new Date;
      ga('create', 'UA-96749385-1', 'auto');
      ga('send', 'pageview');
    </script>
    <script async src='https://www.google-analytics.com/analytics.js'></script>
    <!-- End Google Analytics -->

      </head>

      <body>
          <div id="container">

            <!-- /////// banner-nav.html /////// -->
        
        <div id="nav-wrapper">
          <ul id="nav">
            <li><a href="/suttas/index.html">suttas</a></li>
            <li><a href="#">audio</a>
              <ul>
                            <li><a href="/mp3_index_current.html">evening&nbsp;talks</a>
                  <ul>
                    <li><a href="/mp3_index_current.html">2023</a></li>
                    <li><a href="/mp3_index.html">archive</a></li>
                  </ul>
                </li>
                            <li><a href="/mp3_short_index_current.html">short&nbsp;morning&nbsp;talks</a>
                  <ul>
                    <li><a href="/mp3_short_index_current.html">2023</a></li>
                    <li><a href="/mp3_short_index.html">archive</a></li>
                  </ul>
                </li>
                <li><a href="/mp3_long.php">lectures</a>
                <li><a href="/mp3_guidedMed_index.html">guided&nbsp;meditations</a></li>
                            <li><a href="/mp3_collections_index.html">talk&nbsp;collections</a>
                  <ul>
                    <li><a href="/mp3_collections_index.html">all</a></li>
                    <li><a href="/mp3_collections_index.html#basics">basics</a></li>
                    <li><a href="/mp3_collections_index.html#strengths">five&nbsp;strengths</a></li>
                    <li><a href="/mp3_collections_index.html#seven">seven&nbsp;factors&nbsp;for&nbsp;awakening</a></li>
                    <li><a href="/mp3_collections_index.html#death">refuge&nbsp;from&nbsp;death</a></li>
                    <li><a href="/mp3_collections_index.html#eight">noble&nbsp;eightfold&nbsp;path</a></li>
                    <li><a href="/mp3_collections_index.html#witheachandeverybreath">with&nbsp;each&nbsp;&amp;&nbsp;every&nbsp;breath</a></li>
                    <li><a href="/mp3_topical_index.html">other&nbsp;themes</a></li>
                  </ul>
                </li>
                <li><a href="/chant_index.html">chants</a></li>
                        </ul>
            </li>
            <li><a href="/ebook_index.html">books</a></li>
            <div id="worldMap">
            <li><a href="#"><img src="/images/world-map-silhouette3.png" width="44px" style="vertical-align:middle" /></a>
              <ul>
                <div class="th_nav">
                <li><a href="#">ไทย</a>
                  <ul>
                    <li><a href="/thai_index.html">อบรมภาวนา&nbsp;ตอนเย็น</a></li>
                    <li><a href="/thai_short_index.html">เทศน์ตอนเช้า</a></li>
                    <li><a href="/thai_txt_index.html">หนังสือ</a></li>
                  </ul>
                </li>
                </div><!--end th_nav-->
                <li><a href="#">français</a>
                  <ul>
                    <li><a href="/french_index.html">livres</a></li>
                    <li><a href="/french_mp3_index.html">enseignements&nbsp;audio</a></li>
                  </ul>
                </li>
                <li><a href="/es_txt_index.html">español</a></li>
                <li><a href="/de_txt_index.html">Deutsch</a></li>
                <li><a href="/pt_txt_index.html">português</a></li>
                <div class="ru_nav">
                  <li><a href="/ru_txt_index.html">русский</a></li>
                </div><!--end ru-nav-->
                </ul>
            </li>
            </div><!--end worldMap-->
            <li class="desktop-search">
              <div class="quick-links">
                <input type="text" placeholder="search..." disabled />
                <ul>
                </ul>
              </div>
            </li>
            <li class="mobile-search"><a href="/search.html">search</a></li>
          </ul>
        </div><!--end:nav wrapper-->


            <div id="content">
              <div id="welcome">
                <h1>Evening Dhamma Talks</h1>
                <h4>Current Year</h4>
                <p>These talks were given by Thanissaro Bhikkhu during the evening meditation sessions at Metta Forest Monastery.</p>
                <p>The <a href="/mp3_index.html" class="buried"><span class="pali"><strong>full archive</strong></span></a> of talks back to the year 2000 is also available to search, stream or download. Transcripts of most of the talks are also available there.</p>
                <br />
                <ul>
                  <ul>
                    <ul>
                      <li class="play-random"><button><img src="/images/play-glyph.png" title="stochastic talk selector">Play random talk</button></li>
                <br />
                      <li ><a id="youtubeChannel" class="zip" href="https://www.youtube.com/channel/UC6FSq_ptJ-I6aTHT-XA_e0Q"><img src="/images/youtube48.png" />Youtube channel</a></li>
                <br />
                          <li><a id="eveningPodcast" class="zip" href="/rss/evening.xml"><img src="/images/rss.png" />Dhammatalks.org Evening Talks RSS feed</a></li>
                          <li><a id="applePodcast" class="zip" href="https://podcasts.apple.com/us/podcast/dhammatalks-org-evening-talks/id1569745165"><img src="/images/Apple_podcasts.png" />Also available on Apple Podcasts</a></li>
                          <li><a id="googlePodcast" class="zip" href="https://podcasts.google.com/feed/aHR0cHM6Ly9kaGFtbWF0YWxrcy5vcmcvcnNzL2V2ZW5pbmcueG1s?sa=X&ved=0CBQQ27cFahcKEwj4nZbKxf_wAhUAAAAAHQAAAAAQAg"><img src="/images/Google_podcasts.png" />And on Google Podcasts</a></li>
                    </ul>
                  </ul>
                </ul>

                <ul class="neg-ind"><!--year-->
                  <li class="year" id="2023"><!--2023--></li>
                    <ul><!--month-->

                      <li class="month" id="2023.02">February 2023</li>
                      <ul><!--zip-->
                        <!--<li><a class="zip" href="/Archive/y2023/all_2023_02.zip" title="download zip archive"><img src="/images/zip_48.png" />Full month zip</a></li>  -->
                        <ul><!--indiv-->
                          <li><a href="/Archive/y2023/230209_Developing_the_Path.mp3" class="audio" title="download audio"><span class="smalldate">09</span> Developing the Path</a></li>
                          <li><a href="/Archive/y2023/230208_Realizing_Cessation.mp3" class="audio" title="download audio"><span class="smalldate">08</span> Realizing Cessation</a></li>
                          <li><a href="/Archive/y2023/230207_Abandoning_Craving.mp3" class="audio" title="download audio"><span class="smalldate">07</span> Abandoning Craving</a></li>
                          <li><a href="/Archive/y2023/230206_Comprehending_Suffering.mp3" class="audio" title="download audio"><span class="smalldate">06</span> Comprehending Suffering</a></li>
                          <li><a href="/Archive/y2023/230205_Developing_&_Letting_Go.mp3" class="audio" title="download audio"><span class="smalldate">05</span> Developing &amp; Letting Go</a></li>
                          <li><a href="/Archive/y2023/230204_For_the_Survival_of_True_Happiness.mp3" class="audio" title="download audio"><span class="smalldate">04</span> For the Survival of True Happiness</a></li>
                          <li><a href="/Archive/y2023/230202_Consciousness,_Name,_&_Form_(Reading).mp3" class="audio" title="download audio"><span class="smalldate">02</span> Consciousness, Name, &amp; Form <em>(Reading)</em></a></li>
                        </ul><!--indiv-->
                      </ul><!--zip-->

                      <li class="month" id="2023.01">January 2023</li>
                      <ul><!--zip-->
                        <li><a class="zip" href="/Archive/y2023/all_2023_01.zip" title="download zip archive"><img src="/images/zip_48.png" />Full month zip</a></li>
                        <ul><!--indiv-->
                          <li><a href="/Archive/y2023/230129_The_Projector.mp3" class="audio" title="download audio"><span class="smalldate">29</span> The Projector</a></li>
                          <li><a href="/Archive/y2023/230127_You_Contain_Multitudes.mp3" class="audio" title="download audio"><span class="smalldate">27</span> You Contain Multitudes</a></li>
                          <li><a href="/Archive/y2023/230125_Thinking_About_Rebirth.mp3" class="audio" title="download audio"><span class="smalldate">25</span> Thinking About Rebirth</a></li>
                          <li><a href="/Archive/y2023/230124_Doubt_vs._Discernment.mp3" class="audio" title="download audio"><span class="smalldate">24</span> Doubt <em>vs.</em> Discernment</a></li>
                          <li><a href="/Archive/y2023/230123_The_Fetter_of_Perceptions.mp3" class="audio" title="download audio"><span class="smalldate">23</span> The Fetter of Perceptions</a></li>
                          <li><a href="/Archive/y2023/230122_A_Gift_of_Stillness.mp3" class="audio" title="download audio"><span class="smalldate">22</span> A Gift of Stillness</a></li>
                          <li><a href="/Archive/y2023/230120_The_Armored_Car.mp3" class="audio" title="download audio"><span class="smalldate">20</span> The Armored Car</a></li>
                          <li><a href="/Archive/y2023/230119_Safety_in_an_Uncertain_World.mp3" class="audio" title="download audio"><span class="smalldate">19</span> Safety in an Uncertain World</a></li>
                          <li><a href="/Archive/y2023/230117_Sober_Up.mp3" class="audio" title="download audio"><span class="smalldate">17</span> Sober Up</a></li>
                          <li><a href="/Archive/y2023/230117_Good_Energy_from_Within.mp3" class="audio" title="download audio"><span class="smalldate">17</span> Good Energy from Within</a></li>
                          <li><a href="/Archive/y2023/230116_The_Need_for_Agency.mp3" class="audio" title="download audio"><span class="smalldate">16</span> The Need for Agency</a></li>
                          <li><a href="/Archive/y2023/230115_Events_as_Events.mp3" class="audio" title="download audio"><span class="smalldate">15</span> Events as Events</a></li>
                          <li><a href="/Archive/y2023/230114_Do,_Maintain,_Use.mp3" class="audio" title="download audio"><span class="smalldate">14</span> Do, Maintain, Use</a></li>
                          <li><a href="/Archive/y2023/230113_Goodness_&_Goodwill.mp3" class="audio" title="download audio"><span class="smalldate">13</span> Goodness &amp; Goodwill</a></li>
                          <li><a href="/Archive/y2023/230108_Feeding_on_Open_Wounds.mp3" class="audio" title="download audio"><span class="smalldate">08</span> Feeding on Open Wounds</a></li>
                          <li><a href="/Archive/y2023/230107_Can_Do.mp3" class="audio" title="download audio"><span class="smalldate">07</span> Can Do</a></li>
                          <li><a href="/Archive/y2023/230106_Standing_Outside_Your_Thoughts.mp3" class="audio" title="download audio"><span class="smalldate">06</span> Standing Outside Your Thoughts</a></li>
                          <li><a href="/Archive/y2023/230105_Talking_Among_Your_Selves.mp3" class="audio" title="download audio"><span class="smalldate">05</span> Talking Among Your Selves</a></li>
                          <li><a href="/Archive/y2023/230103_The_Joy_of_Curiousity.mp3" class="audio" title="download audio"><span class="smalldate">03</span> The Joy of Curiosity</a></li>
                          <li><a href="/Archive/y2023/230102_Rivers_of_Craving.mp3" class="audio" title="download audio"><span class="smalldate">02</span> Rivers of Craving</a></li>
                          <li><a href="/Archive/y2023/230101_Mental_Karma.mp3" class="audio" title="download audio"><span class="smalldate">01</span> Mental Karma</a></li>
                        </ul><!--indiv-->
                      </ul><!--zip-->

                    </ul><!--month-->
                </ul><!--end:year-->
              </div><!--end:welcome-->
            </div><!--end:content-->

              <div id="nav-footer-wrapper">
        <div id="nav-footer">
          <ul>
            <li><a href="#" onclick="javascript:history.go(-1);return true;" class="ui-btn clickable" title="back"><img src="/images/actions/go-previous-symbolic-orange.png" width="18px" /></a><br /></li>
            <!--<li><a href="/suttas/index.html" title="suttas home"><img src="/images/actions/go-home-symbolic-orange.png" width="18px" /></a><br /></li>-->
            <li><a href="/search.html" title="search"><img src="/images/actions/search-symbolic-orange.png" width="18px" /></a><br /></li>
            <li><a href="#container" title="top"><img src="/images/actions/go-top-symbolic-orange.png" width="18px" /></a><br /></li>
            <li><a href="/suttas/glossary.html" title="glossary"><img src="/images/actions/glossary-symbolic-orange.png" width="18px" /></a><br /></li>
            <li><a href="#" onclick="window.print();return false;" class="ui-btn clickable" title="print"><img src="/images/actions/document-print-symbolic-orange.png" width="18px" /></a><br /></li>
          </ul>
        </div><!--end:navfooter-->
      </div><!--end:nav-footer-wrapper-->




          </div><!--end:container-->

          <!-------ALL SCRIPTS BELOW HERE-------->

          <!--this puts the logo image into the slicknav menu-->
      <script type="text/javascript">
        $(document).ready(function(){
                        $('.slicknav_menu').prepend('<a href="/index.html"><img src="/images/dto_logo_160x680.png" id="masthead" width="250" alt="home | dhammatalks.org" /></a>');
                    });
      </script>

      <script type="text/javascript">
        $(document).ready(function(){
                        $('div#nav-wrapper').prepend('<a href="/index.html"><img src="/images/dto_logo_160x680.png" id="masthead" width="250" alt="home | dhammatalks.org" /></a>');
                    });
      </script>


          <script src="/js/play-audio.js" async></script>

      </body>
    </html>
    """
}
