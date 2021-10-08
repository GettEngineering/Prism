//
//  File.swift
//  
//
//  Created by Shai Mishali on 04/10/2021.
//

import Foundation

public extension Figma {
    struct Configuration {
        /// Figma File Keys
        public let files: [String]
    }
}

// MARK: - Codable
extension Figma.Configuration: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let singleFile = try? container.decode(String.self, forKey: .file) {
            self.files = [singleFile]
            return
        }

        self.files = try container.decode(.files)
    }

    enum CodingKeys: String, CodingKey {
        case file, files
    }
}
