//
//  WorkflowResponse.swift
//  PrismAgent
//
//  Created by Shai Mishali on 12/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

struct WorkflowResponse: Codable {
    let status: String
    let message: String
    let slug: String
    let service: String
    let buildSlug: String
    let buildNumber: Int
    let buildURL: URL
    let workflow: String

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case slug
        case service
        case buildSlug = "build_slug"
        case buildNumber = "build_number"
        case buildURL = "build_url"
        case workflow = "triggered_workflow"
    }
}
