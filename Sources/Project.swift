//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public extension Prism {
    struct Project: Codable, Equatable {
        public let id: String
        public let name: String
        public let colors: [Prism.Project.Color]
        public let textStyles: [Prism.Project.TextStyle]

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case name
            case colors
            case textStyles
        }

        public func colorIdentity(for color: RawColor) -> AssetIdentity? {
            return colors.first(where: { $0.argbValue == color.argbValue })?.identity
        }
    }
}

extension Prism.Project: CustomDebugStringConvertible {
    public var debugDescription: String {
        let colorDesc = colors.map { "    🎨 \($0.name) \($0.identity) => R: \($0.r), G: \($0.g), B: \($0.b), alpha: \($0.a)" }
                              .joined(separator: "\n")

        let textStylesDesc = textStyles.map { "    ✏️  \($0.name) \($0.identity) => font: \($0.fontFace), size \($0.fontSize)" }
                                       .joined(separator: "\n")
        
        return """
        Project: \(name)

        Colors:
        =========
        \(colorDesc)

        Text Styles:
        =========
        \(textStylesDesc)
        """
    }
}
