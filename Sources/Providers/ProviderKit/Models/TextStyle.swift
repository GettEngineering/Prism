//
//  File.swift
//  
//
//  Created by Shai Mishali on 03/10/2021.
//

import Foundation

public struct TextStyle: Equatable, AssetIdentifiable {
    public let name: String
    public let fontFamily: String
    public let fontPostscriptName: String
    public let fontSize: Float
    public let fontWeight: Int
    public let fontStyle: String
    public let fontStretch: Float
    public let alignment: Alignment?
    public let lineHeight: Float?
    public let lineSpacing: Float?
    public let letterSpacing: Float?
    public let color: Color?

    public init(
        name: String,
        fontFamily: String,
        fontPostscriptName: String,
        fontSize: Float,
        fontWeight: Int,
        fontStyle: String,
        fontStretch: Float,
        alignment: Alignment?,
        lineHeight: Float?,
        lineSpacing: Float?,
        letterSpacing: Float?,
        color: Color?
    ) {
        self.name = name
        self.fontFamily = fontFamily
        self.fontPostscriptName = fontPostscriptName
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.fontStyle = fontStyle
        self.fontStretch = fontStretch
        self.alignment = alignment
        self.lineHeight = lineHeight
        self.lineSpacing = lineSpacing
        self.letterSpacing = letterSpacing
        self.color = color
    }
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
