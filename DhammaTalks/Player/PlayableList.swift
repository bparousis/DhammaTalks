//
//  PlayableList.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

import Combine

protocol PlayableList {

    var playAtIndex: Int { get set }
    
    var playableItems: [any PlayableItem] { get }
    var playPublisher: AnyPublisher<String, Never> { get }
    
    func findIndexOfPlayableItemWithID(_ id: String) -> Int?
}

extension PlayableList {
    func findIndexOfPlayableItemWithID(_ id: String) -> Int? {
        for (index, playableItem) in playableItems.enumerated() {
            if playableItem.id == id {
                return index
            }
        }
        return nil
    }
}
