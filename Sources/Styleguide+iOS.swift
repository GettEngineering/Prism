//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

public struct IOSStyleguideFileProvider: StyleguideFileProviding {
    public init() {
    }

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
        let fontOutput = project.textStyles
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
        return """
        public extension TextStyle {
        \(fontOutput)
        }
        """
    }
}
