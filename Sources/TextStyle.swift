//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public extension Prism.Project {
    struct TextStyle: Codable, Equatable, AssetIdentifiable {
        public let fontFace: String
        public let fontSize: Float
        public let name: String
        public let color: RawColor
        public let lineHeight: Float?
    }
}
