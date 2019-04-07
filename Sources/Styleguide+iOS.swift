//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

public struct IOSStyleguideFileProvider: StyleguideFileProviding {
    public init() { }

    public func colorsFileContents(for colors: [Prism.Project.Color]) -> String {
        let colorOutput = colors
            .map { color in 
                "    static let \(color.identity.iOS) = UIColor(r: \(color.r), g: \(color.g), b: \(color.b), a: \(color.a))"
            }
            .joined(separator: "\n")
        
        return """
        public extension UIColor {
        \(colorOutput)
        }
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

                var attributes = [String]()

                if let lineHeight = textStyle.lineHeight {
                    attributes.append(".lineHeight(\(lineHeight))")
                }

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
        // MARK: - Text Styles

        extension TextStyle {
        \(fontOutput)
        }
        """

        let namesOutput = sortedStyles.reduce(into: "") { string, style in
            string.append("case \"\(style.identity.iOS)\": self = .\(style.identity.iOS)\n            ")
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
