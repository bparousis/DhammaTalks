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
import Combine

class TalkRowViewModelTests: XCTestCase {
    static let someText = "ABCDEFG"
    var sut: TalkRowViewModel!
    var context: NSManagedObjectContext!
    var talkUserInfoService: TalkUserInfoService!
    var urlSession: URLSession!
    fileprivate var fileStorage: MockFileStorage!
    var downloadManager: DownloadManager!

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = { request in
            let exampleData = Self.someText.data(using: .utf8)!
            let response = HTTPURLResponse.init(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
            return (response, exampleData)
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        fileStorage = MockFileStorage()
        downloadManager = DownloadManager(urlSession: urlSession, fileStorage: fileStorage)
        
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
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        XCTAssertEqual(sut.title, "Title")
        XCTAssertEqual(sut.formattedDate, "January 1, 2000")
    }
    
    func testPlayWithTalkUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 14193277562
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 2193277562
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        XCTAssertEqual(sut.state, .unplayed)
        XCTAssertNil(sut.playerItem)
        await sut.play()
        XCTAssertEqual(sut.state, .inProgress)
        XCTAssertNotNil(sut.playerItem)
        
        // Test that seek was performed.
        XCTAssertEqual(sut.playerItem!.currentTime().value, 2193277562)
        XCTAssertEqual(sut.playerItem!.currentTime().timescale, 1000000000)
        XCTAssertEqual(sut.currentTimeString, "00:02")
        XCTAssertEqual(sut.timeRemainingString, "-00:12")
    }
    
    func testPlayWithoutTalkUserInfo() async {
        
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        XCTAssertNil(sut.playerItem)
        await sut.play()
        XCTAssertNotNil(sut.playerItem)

        XCTAssertEqual(sut.playerItem!.currentTime().value, 0)
    }
    
    func testFinishedPlayingUpdatesUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 14193277562
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 2193277562
            try? self.context.save()
        }

        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
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
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
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
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 154433577362
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 8495278262
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        
        sut.fetchTalkInfo()
        XCTAssertEqual(sut.currentTimeInSeconds, 8.495278262)
        XCTAssertEqual(sut.totalTimeInSeconds, 154.433577362)
        XCTAssertEqual(sut.currentTimeString, "00:08")
        XCTAssertEqual(sut.timeRemainingString, "-02:25")
    }
    
    func testAddToFavorites() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        sut.fetchTalkInfo()
        XCTAssertFalse(sut.favorite)
        sut.handleAction(.addToFavorites)
        sut.fetchTalkInfo()
        XCTAssertTrue(sut.favorite)
    }
    
    func testRemoveFromFavorites() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            
            let favoriteDetailsMO = FavoriteDetailsMO(context: self.context)
            favoriteDetailsMO.title = "Title"
            favoriteDetailsMO.dateAdded = Date()
            userInfo.favoriteDetails = favoriteDetailsMO
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        sut.fetchTalkInfo()
        XCTAssertTrue(sut.favorite)
        sut.handleAction(.removeFromFavorites)
        sut.fetchTalkInfo()
        XCTAssertFalse(sut.favorite)
    }

    func testDownload() throws {
        let date = Calendar.current.date(from: DateComponents(year:2000, month: 1, day: 1))
        let talkData = TalkData(id: "1", title: "Title", date: date, url: "about:blank")
        let mockFileStorage = MockFileStorage()
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: DownloadManager(urlSession: urlSession, fileStorage: mockFileStorage))
        XCTAssertNil(mockFileStorage.saveURL)
        let downloadProgress = sut.$downloadProgress
            .collect(2)
            .first()
        sut.handleAction(.download)
        let _ = try awaitPublisher(downloadProgress)
        XCTAssertNotNil(mockFileStorage.saveURL)
    }
    
    func testRemoveDownload() throws {
        let date = Calendar.current.date(from: DateComponents(year:2000, month: 1, day: 1))
        let talkData = TalkData(id: "1", title: "Title", date: date, url: "y2020/test.mp3")
        let mockFileStorage = MockFileStorage()
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: DownloadManager(urlSession: urlSession, fileStorage: mockFileStorage))
        XCTAssertNil(mockFileStorage.performedRemoveFilename)
        sut.handleAction(.removeDownload)
        XCTAssertEqual(mockFileStorage.performedRemoveFilename, "test.mp3")
    }
    
    func testNotes() async {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.notes = "Test Notes"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)
        XCTAssertTrue(sut.notes.isEmpty)
        sut.fetchTalkInfo()
        XCTAssertEqual(sut.notes, "Test Notes")
        sut.notes = "Edited Notes"
        sut.saveNotes()
        sut.notes = ""
        sut.fetchTalkInfo()
        XCTAssertEqual(sut.notes, "Edited Notes")
    }
    
    func testHasNotesFilter() {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")

        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)

        XCTAssertFalse(sut.applyFilter(.hasNotes))

        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.notes = "Test Notes"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)

        XCTAssertTrue(sut.applyFilter(.hasNotes))
    }
    
    func testDownloadedFilter() {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        fileStorage.exists = false

        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: downloadManager)

        XCTAssertFalse(sut.applyFilter(.downloaded))
        
        fileStorage.exists = true
        
        XCTAssertTrue(sut.applyFilter(.downloaded))
    }
    
    func testFavoritedFilter() {
        let talkData = TalkData(id: "1", title: "Title", date: Date(), url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager)
        XCTAssertFalse(sut.applyFilter(.favorited))
        sut.handleAction(.addToFavorites)
        XCTAssertTrue(sut.applyFilter(.favorited))
    }
}

private class MockFileStorage: FileStorage {
    var saveURL: URL?
    var performedRemoveFilename: String?
    var exists = true
    
    func save(at url: URL, withFilename filename: String) throws {
        saveURL = url
    }
    
    func remove(filename: String) throws {
        performedRemoveFilename = filename
    }
    
    func exists(filename: String) -> Bool {
        return exists
    }
    
    func createURL(for filename: String) -> URL {
        return URL(string: "http://google.com")!
    }
    
    func saveData(_ data: Data, withFilename filename: String) throws {
    }
}
