//
//  HTTPLiteTests.swift
//  HTTPLiteTests
//
//  Created by Nawar Nory on 2016-12-04.
//
//

import XCTest
@testable import HTTPLite

class HTTPLiteTests: XCTestCase {
    
    let waitTimeout: TimeInterval = 60
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        guard let request = Request(Url: "http://requestb.in/1f3wbuv1") else {
            XCTFail("Can't intialize the request")
            return
        }
        
        let params: [String: String] = ["rasputin":String(describing:666)]
        
        request.POST(parameters: params, success: { response, url in
            
            if let urlReponse = url {
                print("success to url:\(urlReponse)")
            }
           
            print("response data:\(response)")
            
            expectation.fulfill()
            
        }, failure: { error in
            
            print("error happend in filure closure")
            XCTFail("error: \(error.localizedDescription)")
            
        }, progress: { progress in
            
            if progress > 0 {
                print("progress: \(progress)")
                expectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: waitTimeout) { error in
            print("timedout after \(self.waitTimeout) with error:\(error?.localizedDescription)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
