//
//  MockFileStorage.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2026-03-16.
//  Copyright © 2026 Bill Parousis. All rights reserved.
//

import Foundation

@testable import DhammaTalks

class MockFileStorage: FileStorage {
    var saveURL: URL?
    var performedRemoveFilename: String?
    var exists = true
    var didSaveData = false
    
    func save(at url: URL, withFilename filename: String) throws {
        saveURL = url
    }
    
    func remove(filename: String) throws {
        performedRemoveFilename = filename
    }
    
    func exists(filename: String) -> Bool {
        return exists
    }
    
    func createURL(for filename: String) -> URL {
        return URL(string: "http://google.com")!
    }
    
    func saveData(_ data: Data, withFilename filename: String) throws {
        didSaveData = true
    }
}
