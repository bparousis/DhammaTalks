//
//  AudioPlayerTests.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import AVFoundation
import Testing

@testable import DhammaTalks

class AudioPlayerTests {
    
    private var playableList: MockPlayableList!
    private var sut: AudioPlayer!

    @Test("Empty")
    func testEmpty() async throws {
        sut = AudioPlayer(networkMonitor: MockNetworkMonitor())
        await sut.play()
        #expect(sut.isActive == false)
        #expect(sut.showProgress == false)
    }
    
    @Test("Single item")
    func testSingleItem() async throws {
        playableList = MockPlayableList(playableItems: [MockPlayableItem(id: "item1", title: "Item 1", currentTime: CMTime(value: 2193277562, timescale: 1000000000))])
        sut = AudioPlayer(networkMonitor: MockNetworkMonitor(), dispatcher: MockDispatcher())
        sut.playableList = playableList
        await sut.play()
        #expect(sut.isActive == true)
        #expect(sut.showProgress == true)
    }
    
    @Test("Multiple items")
    func testMultipleItems() async throws {
        playableList = MockPlayableList(playableItems: [
            MockPlayableItem(id: "item1", title: "Item 1", currentTime: CMTime(value: 2193277562, timescale: 1000000000)),
            MockPlayableItem(id: "item2", title: "Item 2", currentTime: CMTime(value: 2193277562, timescale: 1000000000)),
            MockPlayableItem(id: "item3", title: "Item 3", currentTime: CMTime(value: 2193277562, timescale: 1000000000))
        ])
        
        sut = AudioPlayer(networkMonitor: MockNetworkMonitor(), dispatcher: MockDispatcher())
        sut.playableList = playableList
        await sut.play()
        #expect(sut.isActive == true)
        #expect(sut.showProgress == true)
        #expect(sut.title == "Item 1")
        
        var result = await sut.playPrevious()
        #expect(result == false)
        #expect(sut.title == "Item 1")
        
        result = await sut.playNext()
        #expect(result == true)
        #expect(sut.title == "Item 2")
        
        result = await sut.playNext()
        #expect(result == true)
        #expect(sut.title == "Item 3")
        
        result = await sut.playNext()
        #expect(result == false)
        #expect(sut.title == "Item 3")
        
        result = await sut.playPrevious()
        #expect(result == true)
        #expect(sut.title == "Item 2")
    }
}
