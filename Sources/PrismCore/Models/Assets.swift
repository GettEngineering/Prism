//
//  Assets.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ZeplinAPI

/// Prism Assets, representing different colors, text styles and spacing tokens.
public struct Assets: Equatable {
    /// Assets owner.
    public let owner: Owner

    /// Colors.
    public let colors: [Color]

    /// Text Styles.
    public let textStyles: [TextStyle]

    /// Spacing tokens.
    public let spacing: [Spacing]
}

public extension Assets {
    enum Owner: Equatable, CustomStringConvertible {
        case project(id: Project.ID)
        case styleguide(id: Styleguide.ID)

        public var id: String {
            switch self {
            case .project(let id),
                 .styleguide(let id):
                return id
            }
        }

        public var description: String {
            switch self {
            case .project(let id): return "Project \(id)"
            case .styleguide(let id): return "Styleguide \(id)"
            }
        }
    }
}

extension Assets: CustomStringConvertible {
    /// A short description for the project.
    public var description: String {
        "\(owner) has \(colors.count) colors and \(textStyles.count) text styles"
    }
}

extension Assets: CustomDebugStringConvertible {
    /// A verbose description for the project, including its colors and text styles.
    public var debugDescription: String {
        let colorDesc = colors.map { "    🎨 \($0.name) \($0.identity) => R: \($0.r), G: \($0.g), B: \($0.b), alpha: \($0.a)" }
                              .joined(separator: "\n")

        let textStylesDesc = textStyles.map { "    ✏️  \($0.name) \($0.identity) => font: \($0.postscriptName), size \($0.fontSize)" }
                                       .joined(separator: "\n")

        let spacingDesc = spacing.map { "    ↔️ \($0.name) => \($0.value)" }
                                 .joined(separator: "\n")
        
        return """
        \(owner)

        Colors:
        =========
        \(colorDesc)

        Text Styles:
        =========
        \(textStylesDesc)

        Spacing Tokens:
        =========
        \(spacingDesc)
        """
    }
}
