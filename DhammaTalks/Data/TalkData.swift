//
//  TalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkData: Identifiable {

    var id = UUID()

    let fileName: String
    let label: String
    let date: Date

    var url: String {
        let year = Calendar.current.component(.year, from: self.date)
        return "https://www.dhammatalks.org/Archive/y\(year)/\(fileName)"
    }
}

extension TalkData: CustomStringConvertible {
    var description: String {
        // create and return a String that is how
        // you’d like a Store to look when printed
        return " \(label): \(fileName) [\(date)]"
    }
}
