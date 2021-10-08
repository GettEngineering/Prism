//
//  File.swift
//  
//
//  Created by Shai Mishali on 03/10/2021.
//

import Foundation

public struct Color: RawColorRepresentable, AssetIdentifiable {
    public let r: Int
    public let g: Int
    public let b: Int
    public let a: Float
    public let name: String

    public init(r: Int, g: Int, b: Int, a: Float, name: String) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.name = name
    }
}

/// Represents a raw color representable that provides
/// red, green, blue and alpha colors (0-255, 0-255, 0-255, 0.0-1.0).
public protocol RawColorRepresentable: Codable, Equatable {
    var r: Int { get }
    var g: Int { get }
    var b: Int { get }
    var a: Float { get }
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
