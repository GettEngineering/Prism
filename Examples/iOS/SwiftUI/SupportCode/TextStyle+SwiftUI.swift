//
//  TextStyle+SwiftUI.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    /// Applies the provided text style to the view
    ///
    /// - Parameter textStyle: The text style to use in this view
    /// - Returns: A view with the text style applied to it
    public func textStyle(_ textStyle: TextStyle) -> some View {
        self.font(textStyle.font)
            .foregroundColor(textStyle.color)
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension Text {
    /// Applies the provided text style to the text in this view
    ///
    /// - Parameter textStyle: The text style to use in this view
    /// - Returns: A view with the text style applied to it
    public func textStyle(_ textStyle: TextStyle) -> some View {
        self.font(textStyle.font)
            .foregroundColor(textStyle.color)
    }
}

/// Represents a Text Style packing together a text's
/// font, font size and color.
public struct TextStyle {
    /// The text style's font
    let font: Font

    /// The text style's color
    let color: Color

    /// Initialize a new Text Style
    ///
    /// - parameter fontName: The PostScript-styled font name for the font.
    /// - parameter fontSize: The font's size.
    /// - parameter color: The font color.
    init(fontName: String,
         fontSize: Float,
         color: Color) {
        self.font = Font.custom(fontName, size: CGFloat(fontSize))
        self.color = color
    }
}
