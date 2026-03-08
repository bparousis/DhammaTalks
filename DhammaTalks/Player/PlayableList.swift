//
//  PlayableList.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2025-06-28.
//  Copyright © 2025 Bill Parousis. All rights reserved.
//

protocol PlayableList: AnyObject {
    
    var playableItems: [any PlayableItem] { get }
    func playableItemWithID(_ id: String) -> TalkIdentifier?
}

extension PlayableList {
    func playableItemWithID(_ id: String) -> TalkIdentifier? {
        guard let index = playableItems.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        return TalkIdentifier(id: id, index: index)
    }
    
    func random() -> TalkIdentifier? {
        guard let index = playableItems.randomIndex() else { return nil }
        return TalkIdentifier(id: playableItems[index].id, index: index)
    }
}
