//
//  Color.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// Represents a raw color representable that provides
/// red, green, blue and alpha colors (0-255, 0-255, 0-255, 0.0-1.0).
public protocol RawColorRepresentable: Codable, Equatable {
    var r: Int { get }
    var g: Int { get }
    var b: Int { get }
    var a: Double { get }
}

public extension RawColorRepresentable {
    /// A calculated RGB hex string (e.g. #FF0000)
    var rgbValue: String {
        return String(format: "#%02x%02x%02x", r, g, b)
    }

    /// A Calculated ARGB hex string including an
    /// alpha channel. (e.g. #FFFF0000).
    var argbValue: String {
        let alpha = Int(round(a * 255))
        return String(format: "#%02x%02x%02x%02x", alpha, r, g, b)
    }
}

/// A color with a name (identity) as well as color values:
/// red, green, blue and alpha values.
public struct Color: RawColorRepresentable {
    public let name: String
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Double
}

/// A raw color with red, green, blue and alpha values.
public struct RawColor: RawColorRepresentable {
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Double
}
