//
//  Session.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

let errorPrefix = "HTTPLite:Error - "

/**
 Tasks internal handlers
 - Success: a handler that handles successful responses
 - Error: a handler that handles failures
 - Progress: a handler that inform us about a download's progress
 */
typealias successClosure = (URL?) -> ()
typealias failureClosure = (Error) -> ()
typealias progressClosure = (Int64) -> ()

typealias handlers = (success:successClosure,failure:failureClosure, progress: progressClosure)

// MARK: - SessionDelegate

fileprivate class SessionDelegate: NSObject, URLSessionDownloadDelegate {

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
    
    /**
        ## Tasks Delegates
     */
    
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        let session = Session.sharedInstance
        let handlers = session.taskHash[task.taskIdentifier]
        
        switch error {
        case .some:
            handlers?.failure(error!)
        case .none:
            handlers?.success(nil)
        }
       
    }
    
    
    /**
        ## Download Task Delegates
     
     */
 
    /// File Download
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        guard let response = downloadTask.response as? HTTPURLResponse else {
            print(errorPrefix + "issue in converting the response to HTTPURLResponse")
            return
        }
        
        let success = StatusCode.OK.rawValue
        
        guard response.statusCode == success else {
            print(errorPrefix + " - code: \(response.statusCode)")
            return
        }
        
        let sharedSession = Session.sharedInstance
        let handlers = sharedSession.taskHash[downloadTask.taskIdentifier]
        
        handlers?.success(location)
        
    }
    
    /// Task Progress
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten written: Int64,
                    totalBytesExpectedToWrite expected: Int64) {
        
        let progress = 100 * written / expected
        print("downloaded \(progress)%")
        
        let sharedSession = Session.sharedInstance
        let handlers = sharedSession.taskHash[downloadTask.taskIdentifier]
        
        handlers?.progress(progress)
    }


}




  // MARK: - Session

open class Session {
    
    typealias taskId = Int
    static let sharedInstance = Session()

    /**
        ## Session Type
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
     ## Task Hash
        This is a simple dictionary that'll keep track of
        the queued tasks and retrieve them later to assign
        the `success`, `failure` and `progress` completion handlers
        to them respectively
     */
    var taskHash:[taskId:handlers] = [:]
    
    /**
        ## init
        Takes a Session Type argument
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
