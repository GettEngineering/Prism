//
//  TextStyle.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// A Text Style containing a font face, font size, colors and
/// more. It is an `Assetidentifiable` identified by its name.
public struct TextStyle: Codable, Equatable {
    /// Text style ID
    public let id: String

    /// Text style name
    public let name: String
    
    /// Text style's full Postscript name
    public let postscriptName: String
    
    /// Text style's font family
    public let fontFamily: String
    
    /// Text style's font size
    public let fontSize: Float
    
    /// Text style's font weight
    public let fontWeight: Int
    
    /// Text style's font style
    public let fontStyle: String
    
    /// Text style's line height
    public let lineHeight: Float?
    
    /// Text style's letter spacing
    public let letterSpacing: Float?
    
    /// Text style's text alignment
    public let textAlign: Alignment?
    
    /// Text style's raw color
    public let color: RawColor
}

public extension TextStyle {
    /// A text alignment
    enum Alignment: String, Codable {
        case left
        case right
        case center
        case justified
    }
}
