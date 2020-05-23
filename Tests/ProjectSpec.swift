//
//  ProjectSpec.swift
//  Prism
//
//  Created by Shai Mishali on 15/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SnapshotTesting
@testable import PrismCore
@testable import ZeplinAPI

class ZeplinAPISpec: QuickSpec {
    override func spec() {
        describe("Prism+Project") {
            it("should have valid Prism metadata") {
                let output = Project.Platform
                    .allCases
                    .map { "\($0.name): \($0.emoji)" }
                    .joined(separator: "\n")
                
                assertSnapshot(matching: output,
                               as: .lines,
                               named: "Zeplin project Prism metadata")
            }
        }
        
        describe("parsing") {
            context("faulty json") {
                it("should return error") {
                    let project = Project.mock(type: .faultyJSON)
                    
                    guard case .failure(let error) = project,
                          case .decodingFailed(let type, _) = error,
                          type == [Project].self else {
                        fail("Expected decoding falilure, got \(project)")
                        return
                    }
                    
                    expect(try? project.get()).to(beNil())
                }
            }
            
            context("API Error") {
                it("should return error") {
                    let project = Project.mock(type: .apiError)
                    
                    guard case .failure(let error) = project,
                          case .apiError = error else {
                        fail("Expected API Error, got \(project)")
                        return
                    }
                    
                    expect(try? project.get()).to(beNil())
                }
            }
            
            context("Unknown API Error") {
                it("should return error") {
                    let project = Project.mock(type: .unknownApiError)
                    
                    guard case .failure(let error) = project,
                          case .unknownAPIError(let statusCode, _, _) = error,
                          statusCode == 400 else {
                        fail("Expected Unknown API Error, got \(project)")
                        return
                    }
                    
                    expect(try? project.get()).to(beNil())
                }
            }
        }

        describe("Errors") {
            context("localized description") {
                it("should have valid descriptions") {

                    let errors: [ZeplinAPI.Error] = [.apiError(message: "API Message failure"),
                                                     .decodingFailed(type: Project.self, message: "A decoding output"),
                                                     .invalidRequestURL(path: "http://myfakeurl.com"),
                                                     .unknownAPIError(statusCode: 418, url: "http://myfakeurl.com", message: "I'm a teapot")]

                    let descriptions = errors.map { "\($0)" }
                    let expectedDescriptions = [
                        "Zeplin API Failure: API Message failure",
                        "Failed decoding Project: A decoding output",
                        "Failed constructing URL from path 'http://myfakeurl.com'",
                        "An unknown HTTP 418 API error to http://myfakeurl.com occured: I'm a teapot"
                    ]

                    expect(descriptions) == expectedDescriptions
                }
            }
        }
    }
}
