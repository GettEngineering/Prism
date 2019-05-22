//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public protocol RawColorRepresentable: Codable {
    var r: Int { get }
    var g: Int { get }
    var b: Int { get }
    var a: Double { get }
}

public extension RawColorRepresentable {
    var rgbValue: String {
        return String(format: "#%02x%02x%02x", r, g, b)
    }

    var argbValue: String {
        let alpha = Int(round(a * 255))
        return String(format: "#%02x%02x%02x%02x", alpha, r, g, b)
    }
}

public extension Prism.Project {
    struct RawColor: RawColorRepresentable {
        public let r: Int
        public let g: Int
        public let b: Int
        public let a: Double
    }

    struct Color: RawColorRepresentable, AssetIdentifiable {
        public let name: String
        public let r: Int
        public let g: Int
        public let b: Int
        public let a: Double
    }
}
