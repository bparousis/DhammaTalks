//
//  TalkRowViewModelTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-12-03.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

import XCTest
@testable import DhammaTalks
import CoreData
import AVFoundation

class TalkRowViewModelTests: XCTestCase {
    var sut: TalkRowViewModel!
    var context: NSManagedObjectContext!
    var talkUserInfoService: TalkUserInfoService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context = TestCoreDataStack().persistentContainer.viewContext
        talkUserInfoService = TalkUserInfoService(managedObjectContext: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleAndDateLabels() {
        let date = Calendar.current.date(from: DateComponents(year:2000, month: 1, day: 1))
        let talkData = TalkData(id: "1", title: "Title", date: date, url: "about:blank")
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        XCTAssertEqual(sut.title, "Title")
        XCTAssertEqual(sut.formattedDate, "January 1, 2000")
    }
    
    func testPlayWithTalkUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.starred = false
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 14193277562
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 2193277562
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        XCTAssertEqual(sut.state, .unplayed)
        XCTAssertNil(sut.playerItem)
        await sut.play()
        XCTAssertEqual(sut.state, .inProgress)
        XCTAssertNotNil(sut.playerItem)
        
        // Test that seek was performed.
        XCTAssertEqual(sut.playerItem!.currentTime().value, 2193277562)
        XCTAssertEqual(sut.playerItem!.currentTime().timescale, 1000000000)
        XCTAssertEqual(sut.timeRemainingPhrase, "12 sec remaining")
    }
    
    func testPlayWithoutTalkUserInfo() async {
        
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        XCTAssertNil(sut.playerItem)
        await sut.play()
        XCTAssertNotNil(sut.playerItem)

        XCTAssertEqual(sut.playerItem!.currentTime().value, 0)
    }
    
    func testFinishedPlayingUpdatesUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.starred = false
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 14193277562
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 2193277562
            try? self.context.save()
        }

        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        await sut.play()
        
        let beforeFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(beforeFinished)
        XCTAssertEqual(beforeFinished?.currentTime, CMTime(value: 2193277562, timescale: 1000000000))
        
        let item = AVPlayerItem(url: URL(string:"about:blank")!)
        let cmTime = CMTime(value: 8495278262, timescale: 1000000000)
        await item.seek(to: cmTime)
        sut.finishedPlaying(item: item)
        
        let afterFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(afterFinished)
        XCTAssertEqual(afterFinished?.currentTime, cmTime)
    }
    
    func testFinishedPlayingAddsUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        await sut.play()
        
        let beforeFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNil(beforeFinished)
        
        let item = AVPlayerItem(url: URL(string:"about:blank")!)
        let cmTime = CMTime(value: 8495278262, timescale: 1000000000)
        await item.seek(to: cmTime)
        sut.finishedPlaying(item: item)
        
        let afterFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(afterFinished)
        XCTAssertEqual(afterFinished?.currentTime, cmTime)
    }
    
    func testFetchTime() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.starred = false
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 154433577362
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 8495278262
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService)
        
        sut.fetchTalkTime()
        XCTAssertEqual(sut.currentTimeInSeconds, 8.495278262)
        XCTAssertEqual(sut.totalTimeInSeconds, 154.433577362)
        XCTAssertEqual(sut.timeRemainingPhrase, "2 min, 25 sec remaining")
    }
}