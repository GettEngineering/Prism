//
//  ProjectAssets.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ZeplinAPI

/// A Prism Project, with its different colors and text styles.
public struct ProjectAssets: Codable, Equatable {
    /// Project's ID.
    public let id: Project.ID

    /// Project's Colors.
    public let colors: [Project.Color]

    /// Project's Text Styles.
    public let textStyles: [Project.TextStyle]
}

extension ProjectAssets: CustomStringConvertible {
    /// A short description for the project.
    public var description: String {
        return "Zeplin Project \(id) has \(colors.count) colors and \(textStyles.count) text styles"
    }
}

extension ProjectAssets: CustomDebugStringConvertible {
    /// A verbose description for the project, including its colors and text styles.
    public var debugDescription: String {
        let colorDesc = colors.map { "    🎨 \($0.name) \($0.identity) => R: \($0.r), G: \($0.g), B: \($0.b), alpha: \($0.a)" }
                              .joined(separator: "\n")

        let textStylesDesc = textStyles.map { "    ✏️  \($0.name) \($0.identity) => font: \($0.postscriptName), size \($0.fontSize)" }
                                       .joined(separator: "\n")
        
        return """
        Project \(id)

        Colors:
        =========
        \(colorDesc)

        Text Styles:
        =========
        \(textStylesDesc)
        """
    }
}
