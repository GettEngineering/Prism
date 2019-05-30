//
//  Storyboard.swift
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

public extension Prism.Project {
    /// A raw color with red, green, blue and alpha values.
    struct RawColor: RawColorRepresentable {
        public let r: Int
        public let g: Int
        public let b: Int
        public let a: Double
    }

    /// A color with a name (identity) as well as color values:
    /// red, green, blue and alpha values.
    struct Color: RawColorRepresentable, AssetIdentifiable {
        public let name: String
        public let r: Int
        public let g: Int
        public let b: Int
        public let a: Double
    }
}

extension Array where Element == Prism.Project.Color {
    /// Match a provided Raw Color with a Color
    /// from the project, returning its identity if exists.
    ///
    /// - parameter for: Raw color to be matched in the project.
    ///
    /// - returns: Asset Identity for the matched color, if exists in the project.
    func identity<Color: RawColorRepresentable>(matching rawColor: Color) -> Prism.Project.AssetIdentity? {
        return first(where: { $0.argbValue == rawColor.argbValue })?.identity
    }
}
