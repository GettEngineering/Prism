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
    func mock(type: MockType,
              file: StaticString = #file) -> Result<ProjectAssets, ZeplinAPI.Error> {
        MockDuck.shouldFallbackToNetwork = false
        MockDuck.unregisterAllRequestHandlers()
        
        let mocksURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
            .deletingLastPathComponent()
            .appendingPathComponent("Mocks")
            .appendingPathComponent("API")

        MockDuck.registerRequestHandler { request in
            guard let url = request.url else { return nil }
            let path = url.absoluteString
                .replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "?\(url.query ?? "")", with: "")
                .replacingOccurrences(of: "/", with: "_")
            
            guard type == .successful else {
                return try? MockResponse(for: request, data: ",|[".data(using: .utf8))
            }
            
            guard let data = try? Data(contentsOf: mocksURL.appendingPathComponent("\(path).json")) else {
                fatalError("Can't find mock for \(url)")
            }
            
            return try? MockResponse(for: request, data: data)
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

