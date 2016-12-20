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
    
    func testNoLinkGETRequest() {
       
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        guard let request = Request(Url: "https://") else {
            XCTFail("Can't intialize the request")
            return
        }
        
        let params: [String: String] = ["album":"Michael Jackson - Thriller"]
        
//        request.GET(parameters: params, success: { response, url in
//            
//            if let urlReponse = url {
//                print("success with url:\(urlReponse)")
//            }
//            
//            print("response data:\(response)")
//            expectation.fulfill()
//            
//        }, failure: { error in
//            
//            print("error happend in failure closure")
//            XCTFail("error: \(error.localizedDescription)")
//            
//        }, progress: { progress in
//            
//            if progress > 0 {
//                print("progress: \(progress)")
//                expectation.fulfill()
//            }
//        })
//        
        waitForExpectations(timeout: waitTimeout) { error in
            print("timedout after \(self.waitTimeout) with error:\(error?.localizedDescription)")
        }
        
    }
    
    func testGETRequestWithJSON() {
        
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        guard let request = Request(Url: "http://httpbin.org/get") else {
            XCTFail("Can't intialize the request")
            return
        }
        
        let params: [String: String] = ["album":"Michael Jackson - Thriller"]
        
        request.GET(parameters: params, success: { response in
            
            if let data = response.data {
                
                do {
                    let JSON = try JSONSerialization.jsonObject(with: data,
                                                                options: .mutableContainers)
                    print("Data received : \(JSON)")
                    
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
            
            if let url = response.url {
                print("File download finished: \(url)")
            }
            
            expectation.fulfill()
            
        }, failure: { error in
            
            print("error happend in failure closure")
            XCTFail("error: \(error.localizedDescription )")
            
        }) { progress in
            
            if progress > 0 {
                print("progress: \(progress)")
                expectation.fulfill()
            }
            
        }
        
        waitForExpectations(timeout: waitTimeout) { error in
            print("timedout after \(self.waitTimeout) with error:\(error?.localizedDescription)")
        }
    }
    
    func testDownloadingWithGET() {
        
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        guard let request = Request(Url: "http://httpbin.org/image/jpeg") else {
            XCTFail("Can't intialize the request")
            return
        }
        
        let params: [String: String] = ["image":"Random image"]
        
        request.GET(parameters: params, success: { response in
            
            if let data = response.data {
                print("Data received : \(data)")
                let image = UIImage(data: data)
                XCTAssertNotNil(image)
            }
            
            if let url = response.url {
                print("File download finished: \(url)")
            }
            
            expectation.fulfill()
            
        }, failure: { error in
            
            print("error happend in failure closure")
            XCTFail("error: \(error.localizedDescription )")
            
        }) { progress in
            
            if progress > 0 {
                print("progress: \(progress)")
                expectation.fulfill()
            }
            
        }
        
        waitForExpectations(timeout: waitTimeout) { error in
            print("timedout after \(self.waitTimeout) with error:\(error?.localizedDescription)")
        }
    }
    
    
    func testPOSTRequestWithJSON() {
        
        let expectation = self.expectation(description: "HTTPLite-Request")
        
        guard let request = Request(Url: "http://httpbin.org/post") else {
            XCTFail("Can't intialize the request")
            return
        }
        
        let params: [String: String] = ["healer":"Grigori Yefimovich Rasputin", "powers": "healer and adviser"]
        
        request.POST(parameters: params, success: { response in
            
            if let data = response.data {
                
                do {
                    let JSON = try JSONSerialization.jsonObject(with: data,
                                                                options: .mutableContainers)
                    print("Data received : \(JSON)")
                    
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            
            }
            
            if let url = response.url {
                print("success with url:\(url)")
            }
            
            expectation.fulfill()
            
        }, failure: { error in
            
            print("error happend in failure closure")
            XCTFail("error: \(error.localizedDescription)")
            
        }) { progress in
            
        }
        
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
