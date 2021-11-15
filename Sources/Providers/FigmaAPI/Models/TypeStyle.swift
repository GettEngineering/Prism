//
//  TypeStyle.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct TypeStyle: Decodable {
    public let fontFamily: String
    public let fontPostScriptName: String
    public let paragraphSpacing: Float
    public let paragraphIndent: Float
    public let italic: Bool
    public let fontWeight: Float
    public let fontSize: Float
    public let textCase: Node.Text.Case
    public let textDecoration: Node.Text.Decoration
    public let textAutoResize: Node.Text.Autoresize
    public let textAlignHorizontal: Node.Text.HorizontalAlignment
    public let textAlignVertical: Node.Text.VerticalAlignment
    public let letterSpacing: Float
    public let fills: [Paint]
    public let hyperlink: Hyperlink?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fontFamily = try container.decode(.fontFamily)
        self.fontPostScriptName = try container.decode(.fontPostScriptName)
        self.paragraphSpacing = try container.decodeIfPresent(.paragraphSpacing) ?? 0
        self.paragraphIndent = try container.decodeIfPresent(.paragraphIndent) ?? 0
        self.italic = try container.decodeIfPresent(.italic) ?? false
        self.fontWeight = try container.decode(.fontWeight)
        self.fontSize = try container.decode(.fontSize)
        self.textCase = try container.decodeIfPresent(.textCase) ?? .original
        self.textDecoration = try container.decodeIfPresent(.textDecoration) ?? .none
        self.textAutoResize = try container.decodeIfPresent(.textAutoResize) ?? .none
        self.textAlignHorizontal = try container.decode(.textAlignHorizontal)
        self.textAlignVertical = try container.decode(.textAlignVertical)
        self.letterSpacing = try container.decode(.letterSpacing)
        self.fills = try container.decodeIfPresent(.fills) ?? []
        self.hyperlink = try container.decodeIfPresent(.hyperlink)
    }

    enum CodingKeys: String, CodingKey {
        case fontFamily,
             fontPostScriptName,
             paragraphSpacing,
             paragraphIndent,
             italic,
             fontWeight,
             fontSize,
             textCase,
             textDecoration,
             textAutoResize,
             textAlignHorizontal,
             textAlignVertical,
             letterSpacing,
             fills,
             hyperlink
    }
}
