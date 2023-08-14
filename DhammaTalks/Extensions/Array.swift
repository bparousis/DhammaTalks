//
//  Array.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-06.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

extension Array where Element == TalkRowViewModel {
    func playRandom() -> String? {
        guard let randomRow = randomElement() else {
            return nil
        }
        randomRow.play()
        return randomRow.id
    }
}
