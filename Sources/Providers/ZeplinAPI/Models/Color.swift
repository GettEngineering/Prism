//
//  Color.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// A color with a name (identity) as well as color values:
/// red, green, blue and alpha values.
public struct Color: Codable, Equatable {
    public let name: String
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Float
}

/// A raw color with red, green, blue and alpha values.
public struct RawColor: Codable, Equatable {
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Float
}
