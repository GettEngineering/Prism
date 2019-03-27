//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public extension Prism.Project {
    struct TextStyle: Codable, AssetIdentifiable {
        let fontFace: String
        let fontSize: Float
        let name: String
        let color: RawColor
        let lineHeight: Float?
    }
}
