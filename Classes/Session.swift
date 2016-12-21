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
public typealias successClosure = (Response) -> ()
public typealias failureClosure = (Error) -> ()
public typealias progressClosure = (Int64) -> ()

typealias handlers = (success:successClosure,failure:failureClosure, progress: progressClosure)

// MARK: - SessionDelegate

fileprivate class SessionDelegate: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {

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
    
    
    // MARK: - Data Tasks Delegates
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        let taskId = task.taskIdentifier
        let session = Session.sharedInstance
        let handlers = session.taskHash[taskId]
        
        switch error {
        case .some:
            
            handlers?.failure(error!)
        
        case .none:
            
            if let httpResponse = task.response as? HTTPURLResponse {
                
                // in case we downloaded a file using download() function, we'll ignore this
                // as we already removed the taskId from the hashtable
                if let dataForTask = session.taskDataStorage[taskId] {
                    let response = Response(response: httpResponse, data: dataForTask as Data)
                    handlers?.success(response)
                }
            
            }
            
        }
       
        // do the final clean up
        session.taskHash.removeValue(forKey: taskId)
        session.taskDataStorage.removeValue(forKey: taskId)
        
    }
    
    fileprivate func urlSession(_ session: URLSession,
                                dataTask: URLSessionDataTask,
                                didReceive data: Data) {
        
        let taskId = dataTask.taskIdentifier
        let session = Session.sharedInstance
        
        session.taskDataStorage[taskId]?.append(data)

    }
    
    // MARK: - Download Task Delegates
    
    /// File Download
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse else {
            print(errorPrefix + "issue in converting the response to HTTPURLResponse")
            return
        }
       
        let taskId = downloadTask.taskIdentifier
        let session = Session.sharedInstance
        let handlers = session.taskHash[taskId]
        
        let success = StatusCode.OK.rawValue
        
        if httpResponse.statusCode == success {
            
            let response = Response(response: httpResponse,
                                    data: nil,
                                    url: location)
            handlers?.success(response)
        
        } else {

            let error = NSError(domain: NSURLErrorDomain,
                                code: NSURLErrorUnknown,
                                userInfo: ["statusCode" : httpResponse.statusCode])
            handlers?.failure(error)
    
        }
        
        // do the final clean up
        session.taskHash.removeValue(forKey: downloadTask.taskIdentifier)
        
    }
    
    /// Download Task Progress
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten written: Int64,
                    totalBytesExpectedToWrite expected: Int64) {
        
        let progress = 100 * written / expected
        
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
    var taskHash:[taskId : handlers] = [:]
    
    /** 
    ## Task Data Storage
        This is a data storage we use to gather the data
        of each dataTask
    */
    var taskDataStorage:[taskId : NSMutableData] = [:]
    
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
