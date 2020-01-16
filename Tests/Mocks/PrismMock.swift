//
//  PrismMock.swift
//  PrismTests
//
//  Created by Shai Mishali on 22/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
import MockDuck
@testable import PrismCore
@testable import ZeplinAPI

extension Prism {
    func mock(type: MockType) -> Result<ProjectAssets, ZeplinAPI.Error> {
        MockDuck.shouldFallbackToNetwork = false
        MockDuck.unregisterAllRequestHandlers()

        MockDuck.registerRequestHandler { request in
            guard let path = request.url?.absoluteString else { return nil }
            
            guard type == .successful else {
                return try? MockResponse(for: request, data: ",|[".data(using: .utf8))
            }
            
            switch path {
            case _ where path.hasPrefix("https://api.zeplin.dev/v1/projects/12345/colors"):
                let colorsJSONMock = """
                [
                    {
                        "id": "dac9630aec642a428cd73f4be0a03569",
                        "created": 1562834145,
                        "name": "Clear Reddish",
                        "r": 223,
                        "g": 99,
                        "b": 105,
                        "a": 0.79999995
                    },
                    {
                        "id": "53e59fface936ea788f7cf51e7b25531",
                        "created": 1562832145,
                        "name": "Blue Sky",
                        "r": 98,
                        "g": 182,
                        "b": 223,
                        "a": 1
                    }
                ]
                """

                return try? MockResponse(for: request, data: colorsJSONMock.data(using: .utf8))
            case _ where path.hasPrefix("https://api.zeplin.dev/v1/projects/12345/text_styles"):
                let textStylesJSONMock = """
                [
                    {
                        "id":"5cc5a7e87742613db7c802e8",
                        "name":"Large Heading",
                        "created":1517184000,
                        "postscript_name":"MyCustomFont-Light",
                        "font_family":"MyCustomFont",
                        "font_size":32,
                        "font_weight":700,
                        "font_style":"normal",
                        "line_height":24,
                        "font_stretch":1,
                        "text_align":"left",
                        "color": {
                          "r": 223,
                          "b": 105,
                          "g": 99,
                          "a": 0.79999995
                        }
                    },
                    {
                        "id":"5cc5a7e84a92851016fc3041",
                        "name":"Body",
                        "created":1517124000,
                        "font_family":"MyCustomFont",
                        "postscript_name":"MyCustomFont-Regular",
                        "font_size":14,
                        "font_weight":700,
                        "font_style":"normal",
                        "line_height":24,
                        "font_stretch":1,
                        "text_align":"left",
                        "color": {
                          "r": 98,
                          "b": 223,
                          "g": 182,
                          "a": 1
                        }
                    }
                ]
                """
                
                return try? MockResponse(for: request, data: textStylesJSONMock.data(using: .utf8))
            default:
                return nil
            }
        }

        var outResult: Result<ProjectAssets, ZeplinAPI.Error>!
        self.getProjectAssets(for: "12345") { result in
            outResult = result
        }

        return outResult
    }
}

extension Project {
    static func mock(type: MockType) -> Result<[Project], ZeplinAPI.Error> {
        MockDuck.shouldFallbackToNetwork = false
        MockDuck.unregisterAllRequestHandlers()

        MockDuck.registerRequestHandler { request in
            guard let path = request.url?.absoluteString else { return nil }
            
            switch (path, type) {
            case ("https://api.zeplin.dev/v1/projects", .successful):
                let projectsMockJSON = """
                [
                    {
                        "id":"12345",
                        "name":"My Test Project",
                        "description":"A test mock project",
                        "platform":"ios",
                        "thumbnail":"http://placekitten.com/200/300",
                        "status":"active",
                        "scene_url":"https://scene.zeplin.io/project/5db81e73e1e36ee19f138c1a",
                        "created":1517184000,
                        "updated":1572347818,
                        "number_of_members":47,
                        "number_of_screens":112,
                        "number_of_components":46,
                        "number_of_text_styles":28,
                        "number_of_colors":17
                    }
                ]
                """
                
                return try? MockResponse(for: request, data: projectsMockJSON.data(using: .utf8))
            case (_, .successful):
                return nil
            case (_, .failure):
                return try? MockResponse(for: request, data: ",|[".data(using: .utf8))
            case (_, .faultyJSON):
                return try? MockResponse(for: request, data: ",|[".data(using: .utf8))
            case (_, .apiError):
                return try? MockResponse(for: request,
                                         json: ["detail": "A fake detail", "message": "fake message"],
                                         statusCode: 400)
            case (_, .unknownApiError):
            return try? MockResponse(for: request,
                                     json: ["fake": "model"],
                                     statusCode: 400)
            }
        }
        
        let api = ZeplinAPI(jwtToken: "fake")
        var outResult: Result<[Project], ZeplinAPI.Error>!
        let group = DispatchGroup()
        group.enter()
        api.getProjects { projects in
            print(#line, projects)
            outResult = projects
            group.leave()
        }
        
        group.wait()
        
        return outResult
    }
}

enum MockType {
    case successful
    case failure
    case faultyJSON
    case apiError
    case unknownApiError
}

