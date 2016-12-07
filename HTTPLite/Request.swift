//
//  Request.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

open class Request {
    
    /**
    Request types
    - POST: post requests
    - GET: get requests
    */
    enum `Type` {
        case POST
        case GET
    }
    
    let url: URL
    var task: URLSessionTask!
    
    init?(Url: String) {
        guard let link = URL(string: Url) else { return nil }
        url = link
    }
    
    /*
    public func start() {
        task.resume()
    }
    */
    
    func POST(success: @escaping successClosure,
              failure: @escaping failureClosure,
              progress: @escaping progressClosure) {
        
        
        let session = Session.sharedInstance
        task = session.current.dataTask(with: url)
        let handlers = (success: success, failure: failure, progress: progress)
        session.taskHash[task.taskIdentifier] = handlers
        
    }
    
    fileprivate func start() {
        task?.resume()
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
