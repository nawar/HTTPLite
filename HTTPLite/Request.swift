//
//  Request.swift
//  HTTPLite
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import Foundation

open class Request {
    
    /// Request class which represent a data task
    let current: URLSession
    
    /**
    Request types
    - POST: post requests
    - GET: get requests
    */
    enum `Type` {
        case POST
        case GET
    }
    
    init(url: URL) {
        current = Session.sharedInstance.current
    }
    
    /*
    public func start() {
        task.resume()
    }
    */
    
    public func post(url: URL) {
        
    }
    
    
}
