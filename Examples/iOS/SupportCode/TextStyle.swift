//
//  TextStyle.swift
//  Prism
//
//  Created by Shai Mishali on 26/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import UIKit

/// Represents a Text Style packing together a text's
/// font, font size and color.
public struct TextStyle {
    /// The text style's font
    let font: UIFont

    /// The text style's color
    let color: UIColor

    /// The text's alignment

    /// Initialize a new Text Style
    ///
    /// - parameter fontName: The PostScript-styled font name for the font.
    /// - parameter fontSize: The font's size.
    /// - parameter color: The font color.
    /// - parameter alignment: The text's alignment.
    ///
    /// - note: If a font with the provided font name can't be created, a warning will
    ///         be printed out, and a fallback system font will be provided, instead.
    init(fontName: String,
         fontSize: Float,
         color: UIColor,
         alignment: NSTextAlignment = .natural) {
        let ttfURL = Bundle.main.url(forResource: "\(fontName).ttf", withExtension: nil)
        let otfURL = Bundle.main.url(forResource: "\(fontName).otf", withExtension: nil)

        guard let url = ttfURL ?? otfURL else {
            preconditionFailure("Can't locate \(fontName).ttf or \(fontName).otf in the current bundle")
        }

        // Attempt to register font. We don't care about failures in this specific case,
        // since a failure simply means the font was already registered.
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)

        let font = UIFont(name: fontName, size: CGFloat(fontSize))

        switch font {
        case .some(let font):
            self.font = font
        case .none:
            print("[⚠️ WARNING] Cannot locate a font named: \(fontName)! Falling back to system font")

            let weight: UIFont.Weight = {
                if fontName.hasSuffix("-Medium") {
                    return .medium
                } else if fontName.hasSuffix("-Semibold") {
                    return .semibold
                } else {
                    return .regular
                }
            }()

            self.font = UIFont.systemFont(ofSize: CGFloat(fontSize),
                                          weight: weight)
        }

        self.color = color
        self.alignment = alignment
    }
}
