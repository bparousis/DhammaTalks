//
//  DateComponentsFormatter.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-30.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

extension DateComponentsFormatter {

    static let hmsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()
}
