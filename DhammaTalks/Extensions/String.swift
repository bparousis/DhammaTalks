//
//  String.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-10.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

extension String {
    var filename: String {
        if let lastSlashIndex = lastIndex(of: "/") {
            let startIndex = index(after: lastSlashIndex)
            return String(self[startIndex..<endIndex])
        } else {
            return self
        }
    }
}
