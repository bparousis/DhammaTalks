//
//  Calendar.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-19.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

extension Calendar {
    var currentYear: Int {
        component(.year, from: Date())
    }
}
