//
//  Assets.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// Prism Assets, representing different colors, text styles and spacing tokens.
public struct Assets: Equatable {
    /// Colors.
    public let colors: [ProviderCore.Color]

    /// Text Styles.
    public let textStyles: [ProviderCore.TextStyle]

    /// Spacing tokens.
    public let spacing: [ProviderCore.Spacing]

    public init(
        colors: [ProviderCore.Color],
        textStyles: [ProviderCore.TextStyle],
        spacing: [ProviderCore.Spacing]
    ) {
        self.colors = colors
        self.textStyles = textStyles
        self.spacing = spacing
    }
}

extension Assets: CustomStringConvertible {
    /// A short description for the project.
    public var description: String {
        "\(colors.count) colors and \(textStyles.count) text styles"
    }
}

extension Assets: CustomDebugStringConvertible {
    /// A verbose description for the project, including its colors and text styles.
    public var debugDescription: String {
        let colorDesc = colors.map { "    🎨 \($0.name) \($0.identity) => R: \($0.r), G: \($0.g), B: \($0.b), alpha: \($0.a)" }
                              .joined(separator: "\n")

        let textStylesDesc = textStyles.map { "    ✏️  \($0.name) \($0.identity) => font: \($0.fontPostscriptName), size \($0.fontSize)" }
                                       .joined(separator: "\n")

        let spacingDesc = spacing.map { "    ↔️ \($0.name) => \($0.value)" }
                                 .joined(separator: "\n")
        
        return """
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
