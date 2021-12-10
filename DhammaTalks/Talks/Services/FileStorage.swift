//
//  FileStorage.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2021-12-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

protocol FileStorage {
    func save(at url: URL, withFilename filename: String) throws
    func remove(filename: String) throws
    func exists(filename: String) -> Bool
    func createURL(for filename: String) -> URL
}
