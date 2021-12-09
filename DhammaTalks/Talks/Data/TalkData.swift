//
//  TalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkData: Identifiable, Decodable {

    let id: String
    let title: String
    let date: Date?
    let url: String
    
    var filename: String {
        if let lastSlashIndex = url.lastIndex(of: "/") {
            let startIndex = url.index(after: lastSlashIndex)
            return String(url[startIndex..<url.endIndex])
        } else {
            return url
        }
    }
    
    func makeURL() -> URL? {
        guard let talkURL = URL(string: "\(HTMLPageFetcher.archivePath)/\(url)") else {
            return nil
        }
        return talkURL
    }
}

extension TalkData: CustomStringConvertible {
    var description: String {
        // create and return a String that is how
        // you’d like a Store to look when printed
        return " \(title): \(url)"
    }
}
