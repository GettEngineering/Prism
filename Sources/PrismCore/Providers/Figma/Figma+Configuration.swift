//
//  Figma+Configuration.swift
//  Prism
//
//  Created by Shai Mishali on 04/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Figma {
    struct Configuration {
        /// Figma File Keys
        public let files: [String]
    }
}

// MARK: - Codable
extension Figma.Configuration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let singleFile = try? container.decode(String.self, forKey: .file) {
            self.files = [singleFile]
            return
        }

        self.files = try container.decode(.files)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if files.count == 1,
           let file = files.first {
            try container.encode(file, forKey: .file)
        } else {
            try container.encode(files, forKey: .files)
        }
    }

    enum CodingKeys: String, CodingKey {
        case file, files
    }
}
