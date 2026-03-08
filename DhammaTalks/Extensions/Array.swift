//
//  Array.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-02-06.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation

extension Array {
    func randomIndex() -> Int? {
        guard let randomIndex = indices.randomElement() else {
            return nil
        }
        return randomIndex
    }
}
