//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import AppKit

public struct IOSStyleguideFileProvider: StyleguideFileProviding {
    public init() { }

    public var fileHeader: String {
        return """
        /// This file was generated using Prism, Gett's Design System code generator.
        /// https://github.com/gtforge/prism

        """
    }

    public func colorsFileContents(for colors: [Prism.Project.Color]) -> String {
        let colorOutput = colors
            .sorted(by: { $0.identity.iOS < $1.identity.iOS })
            .map { color in
                let alpha = String(format: "%.2f", color.a)
                return "    static let \(color.identity.iOS) = UIColor(r: \(color.r), g: \(color.g), b: \(color.b), alpha: \(alpha))"
            }
            .joined(separator: "\n")
        
        return """
        \(fileHeader)
        import UIKit

        // swiftlint:disable colors
        public extension UIColor {
        \(colorOutput)
        }
        // swiftlint:enable colors
        """
    }

    public func textStylesFileContents(for project: Prism.Project) -> String {
        let sortedStyles = project.textStyles.sorted(by: { $0.identity.iOS < $1.identity.iOS })

        let fontOutput = sortedStyles
            .map { textStyle in
                let textColor: String = {
                    if let matchedColor = project.colors.first(where: { $0.hexValue == textStyle.color.hexValue }) {
                        return ".\(matchedColor.identity.iOS)"
                    } else {
                        return "UIColor(r: \(textStyle.color.r), g: \(textStyle.color.g), b: \(textStyle.color.b), a: \(textStyle.color.a))"
                    }
                }()

                let attributes = [String]()

                // NOTE: We've decided not supporting Attributes for now.
                // There's no real design-use as the line-height / kerning is
                // already baked into the font, and using custom values will
                // require using NSAttributedString(s) which is quite hairy.
                //
                // Feel free to uncomment this if you want to add support
                // in the future.
                //
                //if let lineHeight = textStyle.lineHeight {
                //    attributes.append(".lineHeight(\(lineHeight))")
                //}

                return """
                    static let \(textStyle.identity.iOS) = TextStyle(
                        fontName: "\(textStyle.fontFace)",
                        fontSize: \(textStyle.fontSize),
                        color: \(textColor),
                        attributes: [\(attributes.joined(separator: ", "))]
                    )
                """
            }
            .joined(separator: "\n\n")

        let styles = """
        \(fileHeader)
        import UIKit

        // MARK: - Text Styles

        extension TextStyle {
        \(fontOutput)
        }
        """

        let namesOutput = sortedStyles.reduce(into: "") { string, style in
            string.append("case \"\(style.identity.iOS)\": self = .\(style.identity.iOS)\n        ")
        }

        let styleNames = """
        // MARK: - Text Styles Name (Storyboard Support)
        extension TextStyle {
            /// Returns a TextStyle object based on its string-name.
            /// Can be used by Storyboards to set a Text Style without code.
            ///
            /// - parameter styleName: A String Text Style name.
            ///
            /// - returns: a `TextStyle` object, or `nil` if none matches the name.
            init?(styleName: String) {
                switch styleName {
                \(namesOutput)default: return nil
                }
            }
        }
        """

        return styles + "\n\n" + styleNames
    }
}
