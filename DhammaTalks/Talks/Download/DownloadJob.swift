//
//  DownloadJob.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-01-30.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import CoreGraphics
import Combine
import os.log

class DownloadJob: NSObject {
    
    private let downloadProgressSubject = PassthroughSubject<CGFloat?, Never>()
    var downloadProgressPublisher: AnyPublisher<CGFloat?, Never> {
        downloadProgressSubject.eraseToAnyPublisher()
    }
    
    private let urlSession: URLSession
    private let talkData: TalkData
    private let fileStorage: FileStorage
    private var downloadTask: URLSessionDownloadTask?
    
    init(urlSession: URLSession = .shared, talkData: TalkData, fileStorage: FileStorage = LocalFileStorage()) {
        self.urlSession = urlSession
        self.talkData = talkData
        self.fileStorage = fileStorage
    }

    @discardableResult func start() -> Bool {
        guard let downloadURL = talkData.makeURL() else { return false }
        downloadTask = urlSession.downloadTask(with: downloadURL)
        downloadTask?.delegate = self
        downloadTask?.resume()
        return true
    }
    
    func cancel() {
        downloadTask?.cancel()
        downloadProgressSubject.send(nil)
        downloadProgressSubject.send(completion: .finished)
    }
}

extension DownloadJob: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            try fileStorage.save(at: location, withFilename: talkData.filename)
        } catch {
            Logger.fileStorage.error("Failed to save download: \(String(describing: error))")
        }
        downloadProgressSubject.send(nil)
        downloadProgressSubject.send(completion: .finished)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if totalBytesExpectedToWrite > 0 {
            downloadProgressSubject.send(CGFloat(totalBytesWritten)/CGFloat(totalBytesExpectedToWrite))
        }
    }
}
