//
//  TemplateParser+Token.swift
//  Prism
//
//  Created by Shai Mishali on 29/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ZeplinAPI

extension TemplateParser {
    /// A Token represents an entity within a template that is replaced
    /// with inline values during template parsing.
    ///
    /// Tokens use the {{%tokenName%}} structure, for example {{%textStyle.fontSize%}}.
    enum Token {
        /// Color
        case colorRed(Int)
        case colorGreen(Int)
        case colorBlue(Int)
        case colorAlpha(Double)
        case colorARGB(String)
        case colorRGB(String)
        case colorIdentity(identity: Project.AssetIdentity,
                           style: Project.AssetIdentity.Style)

        /// Text Style
        case textStyleFontName(String)
        case textStyleFontSize(Float)
        case textStyleIdentity(identity: Project.AssetIdentity,
                               style: Project.AssetIdentity.Style)

        /// Parse a raw color token, such as "color.r", into its
        /// appropriate Token case (e.g. `.colorRed(value)` in this case).
        init?(rawToken: String, color: Project.Color) {
            switch rawToken.lowercased() {
            case "color.r":
                self = .colorRed(color.r)
            case "color.g":
                self = .colorGreen(color.g)
            case "color.b":
                self = .colorBlue(color.b)
            case "color.a":
                self = .colorAlpha(color.a)
            case "color.argb":
                self = .colorARGB(color.argbValue)
            case "color.rgb":
                self = .colorRGB(color.rgbValue)
            case "color.identity":
                self = .colorIdentity(identity: color.identity, style: .raw)
            case "color.identity.camelcase":
                self = .colorIdentity(identity: color.identity, style: .camelcase)
            case "color.identity.snakecase":
                self = .colorIdentity(identity: color.identity, style: .snakecase)
            default:
                return nil
            }
        }

        /// Parse a raw text style token, such as "textStyle.fontName", into its
        /// appropriate Token case (e.g. `.textStyleFontName(value)` in this case).
        init?(rawToken: String, textStyle: Project.TextStyle, colors: [Project.Color]) {
            switch rawToken {
            case "textStyle.fontName":
                self = .textStyleFontName(textStyle.fontFamily)
            case "textStyle.fontSize":
                self = .textStyleFontSize(textStyle.fontSize)
            case "textStyle.identity":
                self = .textStyleIdentity(identity: textStyle.identity, style: .raw)
            case "textStyle.identity.camelcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .camelcase)
            case "textStyle.identity.snakecase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .snakecase)
            case "textStyle.color.identity":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .colorIdentity(identity: identity, style: .raw)
            case "textStyle.color.identity.camelcase":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .colorIdentity(identity: identity, style: .camelcase)
            case "textStyle.color.identity.snakecase":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .colorIdentity(identity: identity, style: .snakecase)
            case "textStyle.color.argb":
                self = .colorARGB(textStyle.color.argbValue)
            case "textStyle.color.rgb":
                self = .colorRGB(textStyle.color.rgbValue)
            case "textStyle.color.r":
                self = .colorRed(textStyle.color.r)
            case "textStyle.color.g":
                self = .colorGreen(textStyle.color.g)
            case "textStyle.color.b":
                self = .colorBlue(textStyle.color.b)
            case "textStyle.color.a":
                self = .colorAlpha(textStyle.color.a)
            default:
                return nil
            }
        }

        /// Process the current token, while applying the provided
        /// set of transformations.
        ///
        /// - parameter transformations: An array of Transofmration functions.
        ///
        /// - returns: A processed token value.
        func stringValue(transformations: [Transformation]) -> String {
            let baseString: String
            switch self {
            case .colorAlpha(let a):
                baseString = String(format: "%.2f", a)
            case .colorRed(let c),
                 .colorGreen(let c),
                 .colorBlue(let c):
                baseString = "\(c)"
            case .colorARGB(let hex),
                 .colorRGB(let hex):
                baseString = hex
            case let .colorIdentity(identity, style),
                 let .textStyleIdentity(identity, style):
                baseString = style.identifier(for: identity)
            case .textStyleFontName(let name):
                baseString = name
            case .textStyleFontSize(let size):
                baseString = "\(size)"
            }

            return transformations.reduce(into: baseString) { $0 = $1.apply(to: $0) }
        }
    }
}
