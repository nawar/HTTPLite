//
//  Request.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

/**
 # Request 
 A class encapsulates the most important part of request:
    @param url
*/
class Request {
    
    var url: URL
    var request: URLRequest!
    var task: URLSessionTask!
    
    init?(Url: String) {
        guard let link = URL(string: Url) else { return nil }
        url = link
    }
    
    /**
        ## Request types
        - POST: post requests
        - GET: get requests
     */
    enum `Type`: String {
        case POST = "POST"
        case GET = "GET"
    }
    
    
    // MARK: - Methods Functions
    
    /**
        ## POST
        Sends POST request
        - parameters:
            - parameters: the paraemters in the POST request body
            - success: success handler
            - failure: failure handler
            - progress: progress handler
    */
    func POST(parameters : [String:String], isJSON : Bool = true,
            success: @escaping successClosure,
              failure: @escaping failureClosure,
              progress: @escaping progressClosure) {
        
        // setup the right method
        method(type: .POST, parameters: parameters)
        // pull the shared session
        let session = Session.sharedInstance
        task = session.current.dataTask(with: request)
        // initiate the request handlers
        let handlers = (success: success, failure: failure, progress: progress)
        // add the task to the hash table
        session.taskHash[task.taskIdentifier] = handlers
        // start the task
        start()
    }
    
    /**
     ## GET
     Sends GET request
     - parameters:
     - parameters: the paraemters in the GET request body
     - success: success handler
     - failure: failure handler
     - progress: progress handler
     */
    func GET(parameters : [String:String], isJSON : Bool = true,
              success: @escaping successClosure,
              failure: @escaping failureClosure,
              progress: @escaping progressClosure) {
        
        // setup the right method
        method(type: .GET, parameters: parameters)
        // pull the shared session
        let session = Session.sharedInstance
        task = session.current.dataTask(with: request)
        // initiate the request handlers
        let handlers = (success: success, failure: failure, progress: progress)
        // add the task to the hash table
        session.taskHash[task.taskIdentifier] = handlers
        // start the task
        start()
    }
    
    // MARK: - Helper Functions
    
    /**
     ## HTTP methods wrapper
     supply the method type
     Parameters :
        - type: Type
        - parameters: parameters for the method
     */
    
    func method(type:Type, parameters: [String:String]? ) {
        
        request = URLRequest(url: url)
        
        // fill up the headers
        switch type {
        case .POST:
            // Setup HTTP Body
            if let params = parameters {
                
                if let paramsString = serializer(parameters: params),
                    let paramsData = paramsString.data(using: .utf8) {
                    request.httpBody = paramsData
                }
            
            }
        case .GET:
            
            // If there are parameters, build the query part of the URL then 
            // assign it back
            if let params = parameters,
            let paramsString = serializer(parameters: params),
                let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) {
                components.query = paramsString
                request.url = components.url!
            }
        
        }
        
        // Setup http method
        request.httpMethod = type.rawValue
        
        // NOTE: We skipped building Content-Length as Apple supply it by default
    }
    
    /**
     ### Parameters serializer
     - Parameter parameters: the parameters to serializer
     */
    
    func serializer(parameters: [String:String]) -> String? {
        
        guard !parameters.isEmpty else {
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
       
        if let  urlComponents = NSURLComponents(url: url , resolvingAgainstBaseURL: true) {
        
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                queryItems.append(queryItem)
            }
            
            if !queryItems.isEmpty {
            
                urlComponents.queryItems = queryItems
                return urlComponents.query
        
            }
            
        }
        
        return nil
    }
    
    /// Start a task. A wrapper for resume()
    private func start() {
        task?.resume()
    }
    
    /// Stop a task. A wrapper for cancel()
    func stop() {
        task?.cancel()
    }
    
    deinit {
        request = nil
        task = nil
    }
}

