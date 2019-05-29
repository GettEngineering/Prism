//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public extension Prism.Project {
    /// A Text Style containing a font face, font size,
    /// and color. It is an `Assetidentifiable` identified by its name.
    struct TextStyle: Codable, Equatable, AssetIdentifiable {
        public let fontFace: String
        public let fontSize: Float
        public let name: String
        public let color: RawColor
    }
}
