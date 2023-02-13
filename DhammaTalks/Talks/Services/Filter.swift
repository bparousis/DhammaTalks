//
//  Filter.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2023-02-04.
//  Copyright © 2023 Bill Parousis. All rights reserved.
//

import Foundation

enum Filter: String, Identifiable {
    var id: RawValue { rawValue }

    case empty
    case downloaded
    case favorited
    case hasNotes
    
    var title : String {
        switch self {
        case .empty:
            return "Filter"
        case .downloaded:
            return "Downloaded"
        case .favorited:
            return "Favorited"
        case .hasNotes:
            return "Has Notes"
        }
    }
    
    var imageName: String {
        switch self {
        case .empty:
            return "line.3.horizontal.decrease.circle"
        case .downloaded:
            return "arrow.down.circle.fill"
        case .favorited:
            return "star.fill"
        case .hasNotes:
            return "note.text"
        }
    }
    
    var emptyListText: String {
        switch self {
        case .empty:
            return "No talks"
        case .downloaded:
            return "No downloaded talks"
        case .favorited:
            return "No favorited talks"
        case .hasNotes:
            return "No talks with notes"
        }
    }
}
