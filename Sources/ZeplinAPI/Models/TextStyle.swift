//
//  TextStyle.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public extension Project {
    /// A Text Style containing a font face, font size, colors and
    /// more. It is an `Assetidentifiable` identified by its name.
    struct TextStyle: Codable, Equatable {
        public let name: String
        public let fontFamily: String
        public let fontSize: Float
        public let fontWeight: Int
        public let fontStyle: String
        public let lineHeight: Float?
        public let textAlign: Alignment?
        public let color: RawColor
    }
}

public extension Project.TextStyle {
    enum Alignment: String, Codable {
        case left
        case right
        case center
        case justified
    }
}
