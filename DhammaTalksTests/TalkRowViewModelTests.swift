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
    var playlistService: PlaylistService!
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
        playlistService = PlaylistService(managedObjectContext: context)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testTitleAndDateLabels() {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        XCTAssertEqual(sut.title, "Title")
        XCTAssertNil(sut.formattedDate)
    }

    func testFinishedPlayingUpdatesUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 14193277562
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 2193277562
            try? self.context.save()
        }

        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        
        let beforeFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(beforeFinished)
        XCTAssertEqual(beforeFinished?.currentTime, CMTime(value: 2193277562, timescale: 1000000000))
        
        let item = AVPlayerItem(url: URL(string:"about:blank")!)
        let finishTime = CMTime(value: 8495278262, timescale: 1000000000)
        await item.seek(to: finishTime)
        sut.finishedPlaying(at: finishTime, withTotal: CMTime(value: 14193277562, timescale: 1000000000))
        
        let afterFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(afterFinished)
        XCTAssertEqual(afterFinished?.currentTime, finishTime)
    }
    
    func testFinishedPlayingAddsUserInfo() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)

        let beforeFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNil(beforeFinished)
        
        let item = AVPlayerItem(url: URL(string:"about:blank")!)
        let finishTime = CMTime(value: 8495278262, timescale: 1000000000)
        await item.seek(to: finishTime)
        sut.finishedPlaying(at: finishTime, withTotal: CMTime(value: 14193277562, timescale: 1000000000))
        
        let afterFinished = talkUserInfoService.getTalkUserInfo(for: "about:blank")
        XCTAssertNotNil(afterFinished)
        XCTAssertEqual(afterFinished?.currentTime, finishTime)
    }
    
    func testFetchTime() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.totalTimeScale = 1000000000
            userInfo.totalTimeValue = 154433577362
            userInfo.currentTimeScale = 1000000000
            userInfo.currentTimeValue = 8495278262
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        
        sut.fetchTalkInfo()
        XCTAssertEqual(sut.currentTimeInSeconds, 8.495278262)
        XCTAssertEqual(sut.totalTimeInSeconds, 154.433577362)
        XCTAssertEqual(sut.currentTimeString, "00:08")
    }
    
    func testAddToPlaylist() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        sut.fetchTalkInfo()
        XCTAssertFalse(sut.showPlaylistSelector)
        sut.handleAction(.addToPlaylist)
        XCTAssertTrue(sut.showPlaylistSelector)
    }
    
    func testAddToFavorites() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        sut.fetchTalkInfo()
        XCTAssertFalse(sut.favorite)
        sut.handleAction(.addToFavorites)
        sut.fetchTalkInfo()
        XCTAssertTrue(sut.favorite)
    }
    
    func testRemoveFromFavorites() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            
            let favoriteDetailsMO = FavoriteDetailsMO(context: self.context)
            favoriteDetailsMO.title = "Title"
            favoriteDetailsMO.dateAdded = Date()
            userInfo.favoriteDetails = favoriteDetailsMO
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        sut.fetchTalkInfo()
        XCTAssertTrue(sut.favorite)
        sut.handleAction(.removeFromFavorites)
        sut.fetchTalkInfo()
        XCTAssertFalse(sut.favorite)
    }

    func testDownload() throws {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        let mockFileStorage = MockFileStorage()
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: DownloadManager(urlSession: urlSession, fileStorage: mockFileStorage),
                               playlistService: playlistService)
        XCTAssertNil(mockFileStorage.saveURL)
        let downloadProgress = sut.$downloadProgress
            .collect(2)
            .first()
        sut.handleAction(.download)
        let _ = try awaitPublisher(downloadProgress)
        XCTAssertNotNil(mockFileStorage.saveURL)
    }
    
    func testRemoveDownload() throws {
        let talkData = TalkData(id: "1", title: "Title", url: "y2020/test.mp3")
        let mockFileStorage = MockFileStorage()
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: DownloadManager(urlSession: urlSession, fileStorage: mockFileStorage),
                               playlistService: playlistService)
        XCTAssertNil(mockFileStorage.performedRemoveFilename)
        sut.handleAction(.removeDownload)
        XCTAssertEqual(mockFileStorage.performedRemoveFilename, "test.mp3")
    }
    
    func testShowTranscript() throws {
        let talkData = TalkData(id: "1", title: "Title", url: "y2020/test.mp3")
        sut = TalkRowViewModel(talkData: talkData, talkUserInfoService: talkUserInfoService, downloadManager: DownloadManager(urlSession: urlSession, fileStorage: MockFileStorage()), playlistService: playlistService)
        XCTAssertFalse(sut.showTranscript)
        sut.handleAction(.transcript)
        XCTAssertTrue(sut.showTranscript)
    }
    
    func testNotes() async {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.notes = "Test Notes"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
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
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")

        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)

        XCTAssertFalse(sut.applyFilter(.hasNotes))

        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            userInfo.notes = "Test Notes"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)

        XCTAssertTrue(sut.applyFilter(.hasNotes))
    }
    
    func testDownloadedFilter() {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        fileStorage.exists = false

        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)

        XCTAssertFalse(sut.applyFilter(.downloaded))
        
        fileStorage.exists = true
        
        XCTAssertTrue(sut.applyFilter(.downloaded))
    }
    
    func testFavoritedFilter() {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")
        
        self.context.performAndWait {
            let userInfo = TalkUserInfoMO(context: self.context)
            userInfo.url = "about:blank"
            try? self.context.save()
        }
        
        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        XCTAssertFalse(sut.applyFilter(.favorited))
        sut.handleAction(.addToFavorites)
        XCTAssertTrue(sut.applyFilter(.favorited))
    }
    
    func testPlaylistAction() {
        let talkData = TalkData(id: "1", title: "Title", url: "about:blank")

        sut = TalkRowViewModel(talkData: talkData,
                               talkUserInfoService: talkUserInfoService,
                               downloadManager: downloadManager,
                               playlistService: playlistService)
        XCTAssertFalse(sut.isInPlaylist)
        XCTAssertTrue(sut.actions.contains(.addToPlaylist))
        sut.playlist = Playlist(id: UUID(), title: "Playlist", desc: nil, createdDate: Date(), lastModifiedDate: Date(), playlistItems: [talkData])
        XCTAssertTrue(sut.isInPlaylist)
        XCTAssertFalse(sut.actions.contains(.addToPlaylist))
    }
}
