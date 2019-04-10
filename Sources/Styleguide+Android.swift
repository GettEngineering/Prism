//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public struct AndroidStyleguideFileProvider: StyleguideFileProviding {
    public init() {
    }

    public var fileHeader: String {
        return """
        <!--
        This file was generated using Prism, Gett's Design System code generator.
        https://github.com/gtforge/prism
        -->

        """
    }

    public func colorsFileContents(for colors: [Prism.Project.Color]) -> String {
        let colorOutput = colors
            .map { color in 
                "    <color name=\"\(color.identity.android)\">\(color.hexValue)</color>"
            }
            .joined(separator: "\n")
        
        return """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
        \(colorOutput)
        </resources>
        """
    }

    public func textStylesFileContents(for project: Prism.Project) -> String {
        let textOutput = project.textStyles
            .map { textStyle in 
                let textColor: String
                
                if let matchedColor = project.colors.first(where: { $0.hexValue == textStyle.color.hexValue }) {
                    textColor = "@color/\(matchedColor.identity.android)"
                } else {
                    textColor = textStyle.color.hexValue
                }

                let fontParts = textStyle.fontFace.components(separatedBy: "-")

                guard fontParts.count == 2,
                      let fontFamily = fontParts.first,
                      let fontStyle = fontParts.last?.lowercased() else {
                    fatalError("Invalid font face \(textStyle.fontFace). Can't determine style")
                }

                return """
                    <style name=\"\(textStyle.identity.android)\">
                        <item name="android:textSize">\(Int(textStyle.fontSize))sp</item>
                        <item name="android:fontFamily">\(fontFamily)</item>
                        <item name="android:textColor">\(textColor)</item>
                        <item name="android:textStyle">\(fontStyle)</item>
                    </style>
                """

            }.joined(separator: "\n")

        return """
        <?xml version="1.0" encoding="utf-8"?>
        <resources>
        \(textOutput)
        </resources>
        """
    }
}
