//
//  DownloadManager.swift
//  DhammaTalks
//
//  Created by Bill Parousis on 2022-01-22.
//  Copyright © 2022 Bill Parousis. All rights reserved.
//

import Foundation
import Combine
import os.log

class DownloadManager: ObservableObject {
    
    private let urlSession: URLSession
    private var downloadJobs: [String: (DownloadJob, AnyCancellable)] = [:]
    private let fileStorage: FileStorage

    init(urlSession: URLSession = .shared, fileStorage: FileStorage = LocalFileStorage()) {
        self.urlSession = urlSession
        self.fileStorage = fileStorage
    }

    func createDownloadJob(for talkData: TalkData) -> DownloadJob {
        let downloadJob = DownloadJob(urlSession: urlSession, talkData: talkData, fileStorage: fileStorage)
        let cancellable = downloadJob.downloadProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
            self.downloadJobs[talkData.id] = nil
        } receiveValue: { _ in }
        downloadJobs[talkData.id] = (downloadJob, cancellable)
        return downloadJob
    }
    
    func findDownloadJob(for talkData: TalkData) -> DownloadJob? {
        downloadJobs[talkData.id]?.0
    }
    
    func removeDownload(filename: String) {
        do {
            try fileStorage.remove(filename: filename)
        } catch {
            Logger.fileStorage.error("Failed to remove download: \(String(describing: error))")
        }
    }
    
    func isDownloadAvailable(filename: String) -> Bool {
        fileStorage.exists(filename: filename)
    }
    
    func downloadURL(for filename: String) -> URL? {
        isDownloadAvailable(filename: filename) ? fileStorage.createURL(for: filename) : nil
    }
}
