//
//  LocalAudioStorage.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

struct LocalAudioStorage: AudioStorage {
    
    private let fileManager: FileManager
    private var documentsDirectoryURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func save(at url: URL, withFilename filename: String) throws {
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: destinationUrl.path) {
            try fileManager.removeItem(at: destinationUrl)
        }
        try fileManager.moveItem(at: url, to: destinationUrl)
    }
    
    func remove(filename: String) throws {
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: destinationUrl.path) {
            try fileManager.removeItem(at: destinationUrl)
        }
    }
    
    func isAvailable(filename: String) -> Bool {
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: destinationUrl.path)
    }
    
    func url(for filename: String) -> URL? {
        let url = documentsDirectoryURL.appendingPathComponent(filename)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
}
