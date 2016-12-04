//
//  Session.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation


class SessionDelegate : NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("TBD")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("TBD")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("TBD")
    }
}

class Session {
    
    static let sharedInstance = Session()
    
    enum SessionType {
        case Default
        case Ephemeral
        case Background
    }
    
    // background id for background sessions
    let backgroundId = "HTTPLite-" + UUID().uuidString
    
    // operation queue for HTTP sessions
    let queue: OperationQueue
    
    // Our custom delegate
    let delegate: SessionDelegate
    
    // Sessions's related
    let configuration: URLSessionConfiguration
    let current: URLSession
    
    init(type: SessionType = .Default) {
        
        delegate = SessionDelegate()
        queue = OperationQueue.main
        
        switch type {
        case .Default:
            configuration = URLSessionConfiguration.default
          
        case .Ephemeral:
            configuration = URLSessionConfiguration.ephemeral
     
        case .Background:
            configuration = URLSessionConfiguration.background(withIdentifier: backgroundId)
        }
        
        current = URLSession(configuration: configuration,
                             delegate: delegate,
                             delegateQueue: queue)
    }
    
    deinit {
        // Allow outstanding tasks to finish before invalidating
        current.finishTasksAndInvalidate()
    }
    
}
