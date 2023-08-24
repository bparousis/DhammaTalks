//
//  AudioPlayerTests.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2023-08-11.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import XCTest
import AVFoundation
@testable import DhammaTalks

class AudioPlayerTests: XCTestCase {
    
    var sut: AudioPlayer!

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }
    
    func testEmptyPlayer() async {
        sut = AudioPlayer {
            []
        }
        XCTAssertFalse(sut.hasNext)
        XCTAssertFalse(sut.hasPrevious)

        // When empty, play or pause should effect status.
        XCTAssertEqual(sut.status, .idle)
        await sut.play()
        XCTAssertEqual(sut.status, .idle)
        sut.pause()
        XCTAssertEqual(sut.status, .idle)

        XCTAssertTrue(sut.showPlayButton)

        XCTAssertEqual(sut.totalTimeInSeconds, 0)
        XCTAssertEqual(sut.currentTimeString, "00:00")
        XCTAssertEqual(sut.timeRemainingString, "-00:00")
        
        var result = await sut.playNext()
        XCTAssertFalse(result)
        
        result = await sut.playPrevious()
        XCTAssertFalse(result)
    }
    
    func testPlayerWithOneItem() async {
        let playableItem = MockPlayableItem(id: "1", title: "Talk 1")
        sut = AudioPlayer {
            [playableItem]
        }

        XCTAssertFalse(sut.hasNext)
        XCTAssertFalse(sut.hasPrevious)
        
        XCTAssertTrue(sut.showPlayButton)

        XCTAssertEqual(sut.status, .idle)
        await sut.play()
        XCTAssertEqual(sut.status, .playing)
        await sut.play()
        XCTAssertEqual(sut.status, .playing)
        XCTAssertFalse(sut.showPlayButton)
        sut.pause()
        XCTAssertEqual(sut.status, .paused)
        XCTAssertTrue(sut.showPlayButton)
        
        XCTAssertFalse(playableItem.finishedPlayingCalled)
        sut.finishPlaying()
        XCTAssertTrue(playableItem.finishedPlayingCalled)
        XCTAssertEqual(sut.status, .paused)
        
        var result = await sut.playNext()
        XCTAssertFalse(result)
        
        result = await sut.playPrevious()
        XCTAssertFalse(result)
    }
    
    func testPlayerWithMultipleItems() async {
        let playableItem1 = MockPlayableItem(id: "1", title: "Talk 1")
        let playableItem2 = MockPlayableItem(id: "2", title: "Talk 2")
        let playableItem3 = MockPlayableItem(id: "3", title: "Talk 3")
        sut = AudioPlayer {
            [playableItem1, playableItem2, playableItem3]
        }

        XCTAssertTrue(sut.hasNext)
        XCTAssertFalse(sut.hasPrevious)
        
        XCTAssertTrue(sut.showPlayButton)

        XCTAssertEqual(sut.status, .idle)
        await sut.play()
        XCTAssertEqual(sut.status, .playing)
        await sut.play()
        XCTAssertEqual(sut.status, .playing)
        XCTAssertFalse(sut.showPlayButton)
        sut.pause()
        XCTAssertEqual(sut.status, .paused)
        XCTAssertTrue(sut.showPlayButton)
        
        XCTAssertFalse(playableItem1.finishedPlayingCalled)
        var result = await sut.playNext()
        XCTAssertTrue(result)
        XCTAssertTrue(playableItem1.finishedPlayingCalled)
        
        XCTAssertEqual(sut.status, .playing)
        XCTAssertTrue(sut.hasNext)
        XCTAssertTrue(sut.hasPrevious)
        
        XCTAssertFalse(playableItem2.finishedPlayingCalled)
        result = await sut.playNext()
        XCTAssertTrue(result)
        XCTAssertTrue(playableItem2.finishedPlayingCalled)
        
        
        XCTAssertFalse(playableItem3.finishedPlayingCalled)
        result = await sut.playNext()
        XCTAssertFalse(result)
        XCTAssertFalse(playableItem3.finishedPlayingCalled)
        
        result = await sut.playPrevious()
        XCTAssertTrue(result)
        XCTAssertTrue(playableItem2.finishedPlayingCalled)
    }
    
    func testTimeDisplay() async {
        let playableItem = MockPlayableItem(id: "1", title: "Talk 1")
        sut = AudioPlayer {
            [playableItem]
        }

        let cmTime = CMTime(value: 8495278262, timescale: 1000000000)
        
        await sut.play()
        XCTAssertEqual(sut.timeRemainingString, "-00:25")
        await playableItem.avPlayerItem.seek(to: cmTime)
        XCTAssertEqual(sut.currentTimeString, "00:08")
        XCTAssertEqual(sut.timeRemainingString, "-00:16")
    }
}
