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
        url.filename
    }
    
    func makeURL() -> URL? {
        guard let talkURL = URL(string: "\(HTMLPageFetcher.archivePath)/\(url)") else {
            return nil
        }
        return talkURL
    }
}
