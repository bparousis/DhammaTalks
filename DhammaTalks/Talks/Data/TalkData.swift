//
//  TalkData.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2020-01-11.
//  Copyright © 2020 Bill Parousis. All rights reserved.
//

import Foundation

struct TalkData: Identifiable, Decodable, Hashable {

    static let archivePath = "https://www.dhammatalks.org/Archive"

    let id: String
    let title: String
    let url: String
    let date: Date?
    let transcribeLink: String?
    var showDay: Bool = true
    
    private let streamingLink: String?

    init(id: String, title: String, url: String) {
        self.id = id
        self.title = title
        self.url = url
        self.streamingLink = "\(Self.archivePath)/\(url)"
        self.date = AudioFileNameParser.extractDate(url.filename)
        self.transcribeLink = nil
    }

    init(seriesTalkData: SeriesTalkData) {
        self.init(id: seriesTalkData.id, title: seriesTalkData.title, url: seriesTalkData.url)
    }
    
    init(serverTalkData: CollectionTalkData) {
        self.id = serverTalkData.id
        self.title = serverTalkData.talkTitle
        self.url = serverTalkData.url
        self.streamingLink = serverTalkData.streamingLink
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        self.date = serverTalkData.date
        self.showDay = serverTalkData.isDayValid
        self.transcribeLink = serverTalkData.transcribeLink.isEmpty
                                    ? nil : serverTalkData.transcribeLink
    }

    var filename: String {
        url.filename
    }

    func makeURL() -> URL? {
        guard let streamingLink else {
            return nil
        }
        return URL(string: streamingLink)
    }

    var transcribeURL: URL? {
        guard let transcribeLink, let transcribeURL = URL(string: transcribeLink) else {
            return nil
        }
        return transcribeURL
    }
}
