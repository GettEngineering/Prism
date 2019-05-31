//
//  PrismMock.swift
//  PrismTests
//
//  Created by Shai Mishali on 22/05/2019.
//

import Foundation
import Quick
import Nimble
import MockDuck
@testable import PrismCore

extension PrismAPI {
    func mock(type: MockType) -> ProjectResult {
        MockDuck.shouldFallbackToNetwork = type != .failure
        MockDuck.unregisterAllRequestHandlers()

        MockDuck.registerRequestHandler { request in
            if request.url?.absoluteString == "https://api.zeplin.io/v2/projects/12345" {
                switch type {
                case .successful:
                    return try? MockResponse(for: request, data: projectJSONMock.data(using: .utf8))
                case .faultyJSON:
                    return try? MockResponse(for: request, data: ",|[".data(using: .utf8))
                case .failure:
                    return nil
                }
            } else {
                return nil
            }
        }

        return WaitForResult<ProjectResult> { done in
            self.getProject(id: "12345") { result in
                done(result)
            }
        }.result
    }

    enum MockType {
        case successful
        case failure
        case faultyJSON
    }
}

private let projectJSONMock = """
{
  "_id": "5xxad123dsadasxsaxsa",
  "name": "Fake Project Test",
  "type": "ios",
  "icon": {
    "type": "elephant"
  },
  "created": "2019-04-24T08:47:02.000Z",
  "updated": "2019-05-22T14:38:40.861Z",
  "density": "1x",
  "colors": [
    {
      "_id": "dac9630aec642a428cd73f4be0a03569",
      "b": 105,
      "name": "Clear Reddish",
      "a": 0.79999995,
      "g": 99,
      "r": 223
    },
    {
      "_id": "53e59fface936ea788f7cf51e7b25531",
      "b": 223,
      "name": "Blue Sky",
      "a": 1,
      "g": 182,
      "r": 98
    }
  ],
  "textStyles": [
    {
      "_id": "5cc5a7e87742613db7c802e8",
      "name": "Large Heading",
      "fontSize": 32,
      "fontFace": "MyCustomFont-Light",
      "color": {
        "r": 223,
        "b": 105,
        "g": 99,
        "a": 0.79999995
      }
    },
    {
      "_id": "5cc5a7e84a92851016fc3041",
      "name": "Body",
      "fontSize": 14,
      "fontFace": "MyCustomFont-Regular",
      "color": {
        "r": 98,
        "b": 223,
        "g": 182,
        "a": 1
      }
    }
  ]
}
"""
