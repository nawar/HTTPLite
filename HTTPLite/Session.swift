//
//  Session.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

let errorPrefix = "HTTPLite:Error - "

// MARK: - SessionDelegate

fileprivate class SessionDelegate: NSObject, URLSessionDownloadDelegate {

    /**
        Tasks internal handlers
        - Success: a handler that handles successful responses
        - Error: a handler that handles failures
        - Progress: a handler that inform us about a download's progress
    */
    typealias successHandler = (() -> Void)
    typealias errorHandler = (() -> Void)
    typealias progressHandler = (() -> Void)
    
    typealias taskId = Int

    
    /**
        HTTP Status codes for responses
        - 2xx Success
        - 3xx Redirection 
        - 4xx Client Error
        - 5xx Server Error
    */
    enum StatusCode: Int {
        // MARK: 2xx codes
        case OK     = 200
        // MARK: 3xx codes
        case MovedPermanently = 301
        case Found  = 302
        // MARK: 4xx codes
        case BadRequest = 400
        case Unauthorized = 401
        case NotFound = 404
    }
    
    var tasksHash: [taskId:URLSessionTask] = [:]

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        print("completed: error: \(error)")
        
    }
    
    /**
     Download Task Delegates
     
     */
 
    /// File Download
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        guard let response = downloadTask.response as? HTTPURLResponse else {
            print("issue in converting the response to HTTPURLResponse")
            return
        }
        
        let success = StatusCode.OK.rawValue
        
        guard response.statusCode == success else {
            print("\(errorPrefix) - code: \(response.statusCode)")
            return
        }
        
        guard let tempFile = try? Data(contentsOf: location) else {
            print(errorPrefix + "reading temporary file")
            return
        }
        
        
    }
    
    /// Task Progress
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten written: Int64,
                    totalBytesExpectedToWrite expected: Int64) {
        
        print("downloaded \(100 * written / expected)%")
        
    }


}




  // MARK: - Session

open class Session {
    
    static let sharedInstance = Session()
    
    /** 
        Session Type
        - Default
        - Ephemeral
        - Background
     */
    
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
    private let delegate: SessionDelegate
    
    // Sessions's related
    let configuration: URLSessionConfiguration
    let current: URLSession
    
    /**
        init: Takes a Session Type argument
        
        - Parameter type: SessionType
    */
    
    init(type: SessionType = .Default) {
        
        delegate = SessionDelegate()
        queue = OperationQueue() // create
        queue.name = "HTTPLite-Queue"
        
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
