//
//  Request.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

class Request {
    
    let url: URL
    var this: URLRequest!
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
        ## HTTP methods wrapper
        supply the method type
        - Parameter type: Type
    */
    
    func method(type:Type) {
        
        // fill up the headers
        switch type {
        case .POST:
            this.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type") // for simple form data
            //request.setValue("application/form-data" forHTTPHeaderField:"Content-Type") //binary form data
        default: break
        
        }
        
        this = URLRequest(url: url)
        this.httpMethod = type.rawValue
        // more to come
        
    }
    
    func POST(success: @escaping successClosure,
              failure: @escaping failureClosure,
              progress: @escaping progressClosure) {
        
        // setup the right method
        method(type: .POST)
        // pull the shared session
        let session = Session.sharedInstance
        task = session.current.dataTask(with: this)
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


/*
let requ = Request(Url: "")?.POST(success: { (<#URL#>) in
    <#code#>
}, failure: { (<#Error#>) in
    <#code#>
}, progress: { (<#Int#>) in
    <#code#>
})

*/
