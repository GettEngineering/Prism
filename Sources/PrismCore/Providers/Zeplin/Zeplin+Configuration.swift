//
//  Zeplin+Configuration.swift
//  Prism
//
//  Created by Shai Mishali on 02/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Zeplin {
    struct Configuration {
        /// Zeplin Project ID
        public let projectId: String?

        /// Zeplin Styleguide ID
        public let styleguideId: String?
    }
}

// MARK: - Codable
extension Zeplin.Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case styleguideId = "styleguide_id"
    }
}
