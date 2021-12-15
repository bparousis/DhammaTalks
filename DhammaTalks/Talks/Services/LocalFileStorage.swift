//
//  LocalAudioStorage.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-08.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

struct LocalFileStorage: FileStorage {

    private enum FileType {
        case audio
        case html
        case misc
        
        var directory: String {
            switch self {
            case .audio:
                return "audio"
            case .html:
                return "html"
            case .misc:
                return "misc"
            }
        }
        
        static func fileTypeForFilename(_ filename: String) -> FileType {
            if filename.hasSuffix(".mp3") {
                return audio
            } else if filename.hasSuffix(".html") || filename.hasSuffix(".htm") {
                return html
            } else {
                return misc
            }
        }
    }
    
    private let fileManager: FileManager
    private var documentsDirectoryURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func save(at url: URL, withFilename filename: String) throws {
        try createDirectoryIfNeeded(for: filename)
        let destinationUrl = createURL(for: filename)
        if fileManager.fileExists(atPath: destinationUrl.path) {
            try fileManager.removeItem(at: destinationUrl)
        }
        try fileManager.moveItem(at: url, to: destinationUrl)
    }
    
    func saveData(_ data: Data, withFilename filename: String) throws {
        try createDirectoryIfNeeded(for: filename)
        let destinationUrl = createURL(for: filename)
        try data.write(to: destinationUrl)
    }
    
    func remove(filename: String) throws {
        let destinationUrl = createURL(for: filename)
        if fileManager.fileExists(atPath: destinationUrl.path) {
            try fileManager.removeItem(at: destinationUrl)
        }
    }
    
    func exists(filename: String) -> Bool {
        fileManager.fileExists(atPath: createURL(for: filename).path)
    }
    
    func createURL(for filename: String) -> URL {
        let directory = FileType.fileTypeForFilename(filename).directory
        return documentsDirectoryURL.appendingPathComponent(directory).appendingPathComponent(filename)
    }
    
    private func createDirectoryIfNeeded(for filename: String) throws {
        let fileType = FileType.fileTypeForFilename(filename)
        let directory = documentsDirectoryURL.appendingPathComponent(fileType.directory)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: false)
        }
    }
}
