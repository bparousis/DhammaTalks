//
//  Sort.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2024-07-10.
//  Copyright © 2024 Bill Parousis. All rights reserved.
//

import Foundation

enum Sort: String, CaseIterable, Identifiable {

    var id: RawValue { rawValue }

    case lastModifiedDate
    case createdDate
    case atoz
    case ztoa

    var title : String {
        switch self {
        case .atoz:
            "A to Z"
        case .ztoa:
            "Z to A"
        case .createdDate:
            "Created"
        case .lastModifiedDate:
            "Last Modified"
        }
    }
    
    private var descriptorKey: String {
        switch self {
        case .atoz, .ztoa:
            "title"
        case .createdDate:
            "createdDate"
        case .lastModifiedDate:
            "lastModifiedDate"
        }
    }
    
    private var isAscending: Bool {
        switch self {
        case .atoz:
            true
        case .ztoa, .createdDate, .lastModifiedDate:
            false
        }
    }
    
    var sortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: descriptorKey, ascending: isAscending)
    }
}
