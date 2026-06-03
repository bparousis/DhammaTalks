//
//  PlaybackSpeed.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-05-30.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

enum PlaybackSpeed: Float, CaseIterable {
    case slowest = 0.75
    case slower = 0.85
    case normal = 1.0
    case fastest = 1.15

    var pillLabel: String {
        "\(rawValue.formatted(.number.precision(.fractionLength(1...2))))x"
    }
    
    var label: String {
        if self == .normal {
            "\(pillLabel) (Normal)"
        } else {
            "\(pillLabel)"
        }
    }
}
