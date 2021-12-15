//
//  DateFormatter.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-11-30.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let monthDayYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter
    }()
    
    static let dayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter
    }()
}
