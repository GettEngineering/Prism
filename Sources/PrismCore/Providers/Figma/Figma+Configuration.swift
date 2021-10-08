//
//  File.swift
//  
//
//  Created by Shai Mishali on 04/10/2021.
//

import Foundation

public extension Figma {
    struct Configuration {
        /// Figma File Key
        public let fileKey: String
    }
}

// MARK: - Codable
extension Figma.Configuration: Codable {
    enum CodingKeys: String, CodingKey {
        case fileKey = "file_key"
    }
}
