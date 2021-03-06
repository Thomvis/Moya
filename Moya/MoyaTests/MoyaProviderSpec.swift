//
//  MoyaProviderSpec.swift
//  MoyaTests
//
//  Created by Ash Furrow on 2014-08-16.
//  Copyright (c) 2014 Ash Furrow. All rights reserved.
//

import UIKit
import Quick
import Nimble
import Moya


class MoyaProviderSpec: QuickSpec {
    override func spec() {
        describe("valid enpoints") {
            var sampleData: NSData!
            beforeEach {
                let bundle = NSBundle(forClass: self.dynamicType)
                let path = bundle.pathForResource("300_200", ofType: "png")
                sampleData = NSData(contentsOfFile: path)
                
            }
            
            describe("with stubbed data") {
                let endpointsClosure = { (target: Target, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<Target> in
                    switch target {
                    case .MediumImage:
                        return Endpoint(URL: "http://rdjpg.com/300/200/", sampleResponse: {
                            return sampleData
                        })
                    }
                }
                
                describe("a provider", { () -> () in
                    var provider: MoyaProvider<Target>!
                    beforeEach {
                        provider = MoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
                    }
                    
                    it("returns stubbed data for a request") {
                        var response: NSData?
                        
                        provider.request(.MediumImage, completion: { (object: AnyObject?, error: NSError?) -> () in
                            response = object as? NSData
                        })
                        
                        expect{response}.toEventually(equal(sampleData), timeout: 1, pollInterval: 0.1)
                    }
                })
                
                describe("a reactive provider", { () -> () in
                    var provider: ReactiveMoyaProvider<Target>!
                    beforeEach {
                        provider = ReactiveMoyaProvider(endpointsClosure: endpointsClosure, stubResponses: true)
                    }
                    
                    it("returns stubbed data for a request") {
                        var response: NSData?
                        
                        provider.request(.MediumImage).subscribeNext({ (object: AnyObject!) -> Void in
                            response = object as? NSData
                        })
                        
                        expect{response}.toEventually(equal(sampleData), timeout: 1, pollInterval: 0.1)
                    }
                })
            }
        }
    }
}
