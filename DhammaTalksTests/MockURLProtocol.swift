//
//  MockURLProtocol.swift
//  DhammaTalksTests
//
//  Created by Bill Parousis on 2021-12-09.
//  Copyright © 2021 Bill Parousis. All rights reserved.
//

import Foundation

enum MockError: Error {
    case someError
}

class MockURLProtocol: URLProtocol {
 
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data) )?
    
    static var requestURLHistory: [String] = []
    static var failWithRequest: String?
    
    static func reset() {
        requestURLHistory.removeAll()
        failWithRequest = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func stopLoading() {}

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        
        if let requestURL = request.url?.absoluteString {
            Self.requestURLHistory.append(requestURL)
            
            if let failWithRequest = Self.failWithRequest, failWithRequest == requestURL {
                client?.urlProtocol(self, didFailWithError: MockError.someError)
                return
            }
        }

        do {
            let (response, data)  = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch  {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
