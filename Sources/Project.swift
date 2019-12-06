//
//  Project.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// A Prism Project, providing a name along with its different
/// colors and text styles.
public struct Project: Codable, Equatable {
    /// Project's ID.
    public let id: String

    /// Project's Name.
    public let name: String

    /// Project's Colors.
    public let colors: [Project.Color]

    /// Project's Text Styles.
    public let textStyles: [Project.TextStyle]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case colors
        case textStyles
    }
}

extension Project: CustomStringConvertible {
    /// A short description for the project.
    public var description: String {
        return #"Zeplin Project "\(name)" has \(colors.count) colors and \(textStyles.count) text styles"#
    }
}

extension Project: CustomDebugStringConvertible {
    /// A verbose description for the project, including its colors and text styles.
    public var debugDescription: String {
        let colorDesc = colors.map { "    🎨 \($0.name) \($0.identity) => R: \($0.r), G: \($0.g), B: \($0.b), alpha: \($0.a)" }
                              .joined(separator: "\n")

        let textStylesDesc = textStyles.map { "    ✏️  \($0.name) \($0.identity) => font: \($0.fontFace), size \($0.fontSize)" }
                                       .joined(separator: "\n")
        
        return """
        Project: \(name)

        Colors:
        =========
        \(colorDesc)

        Text Styles:
        =========
        \(textStylesDesc)
        """
    }
}
