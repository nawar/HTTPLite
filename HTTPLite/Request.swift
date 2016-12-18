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
    
    let url: URL
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
    
    /**
        ### Parameters builder
        - Parameter parameters: the parameters to build
    */
    
    func builder(parameters: [String:String]) -> String {
        
        var count = parameters.count
        var paramsString: String = ""
        
        for (key,value) in parameters {
            
            paramsString += key + "=" + value
            count -= 1
            if count > 0 {
                paramsString += "&"
            }
            
        }
        
        return paramsString
    }
    
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
            request.setValue("application/x-www-form-urlencoded",
                          forHTTPHeaderField:"Content-Type") // for simple form data
            //request.setValue("application/form-data" forHTTPHeaderField:"Content-Type") //binary form data
        default: break
        
        }

        // Setup HTTP Body
        var paramsString = ""
        var paramsBodyLength = 0
        
        if let params = parameters {
            
            paramsString = builder(parameters: params)
            
            if let paramsData = paramsString.data(using: .utf8), !paramsString.isEmpty {
                paramsBodyLength = paramsData.count
                request.httpBody = paramsData
            }
            
        }

        // Setup Content-Length header
        let contentLength = String(paramsBodyLength)
        request.setValue(contentLength, forHTTPHeaderField:"Content-Length")
        
        request.httpMethod = type.rawValue

    }
    
    /**
        ## POST
        Sends post request
        - parameters:
            - parameters: the paraemters in the POST request body
            - success: success handler
            - failure: failure handler
            - progress: progress handler
    */
    func POST(parameters:[String:String], isJSON: Bool = true,
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
    
    private func start() {
        task?.resume()
    }
    
    func stop() {
        task?.cancel()
    }
    
    deinit {
        task = nil
    }
}

