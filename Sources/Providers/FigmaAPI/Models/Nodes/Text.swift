//
//  Text.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    @dynamicMemberLookup
    struct Text: VectorNodeType, Decodable {
        public let vector: Vector
        public let characters: String
        public let style: TypeStyle

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.characters = try container.decode(.characters)
            self.style = try container.decode(.style)
        }

        enum CodingKeys: String, CodingKey {
            case characters, style
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }

        public enum Case: String, Decodable {
            case original = "ORIGINAL"
            case uppercase = "UPPER"
            case lowercase = "LOWER"
            case titlecase = "TITLE"
            case smallCaps = "SMALL_CAPS"
            case smallCapsForced = "SMALL_CAPS_FORCED"
        }

        public enum Decoration: String, Decodable {
            case none = "NONE"
            case strikethrough = "STRIKETHROUGH"
            case underline = "UNDERLINE"
        }

        public enum Autoresize: String, Decodable {
            case none = "NONE"
            case height = "HEIGHT"
            case widthAndHeight = "WIDTH_AND_HEIGHT"
        }

        public enum HorizontalAlignment: String, Decodable {
            case left = "LEFT"
            case right = "RIGHT"
            case center = "CENTER"
            case justified = "JUSTIFIED"
        }

        public enum VerticalAlignment: String, Decodable {
            case top = "TOP"
            case center = "CENTER"
            case bottom = "BOTTOM"
        }
    }

}
