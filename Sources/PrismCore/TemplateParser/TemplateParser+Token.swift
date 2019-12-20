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
        init(rawToken: String, color: Project.Color) throws {
            let cleanToken = rawToken.lowercased()
            guard cleanToken.hasPrefix("color.") else {
                throw Error.unknownToken(token: rawToken)
            }
            
            let colorToken = String(cleanToken.dropFirst(6))
            
            switch colorToken {
            case "r":
                self = .colorRed(color.r)
            case "g":
                self = .colorGreen(color.g)
            case "b":
                self = .colorBlue(color.b)
            case "a":
                self = .colorAlpha(color.a)
            case "argb":
                self = .colorARGB(color.argbValue)
            case "rgb":
                self = .colorRGB(color.rgbValue)
            case "identity":
                self = .colorIdentity(identity: color.identity, style: .raw)
            case "identity.camelcase":
                self = .colorIdentity(identity: color.identity, style: .camelcase)
            case "identity.snakecase":
                self = .colorIdentity(identity: color.identity, style: .snakecase)
            default:
                throw Error.unknownToken(token: rawToken)
            }
        }

        /// Parse a raw text style token, such as "textStyle.fontName", into its
        /// appropriate Token case (e.g. `.textStyleFontName(value)` in this case).
        init(rawToken: String, textStyle: Project.TextStyle, colors: [Project.Color]) throws {
            let cleanToken = rawToken.lowercased()
            guard cleanToken.hasPrefix("textstyle.") else {
                throw Error.unknownToken(token: rawToken)
            }
            
            let textStyleToken = String(cleanToken.dropFirst(10))

            switch textStyleToken {
            case "fontname",
                 "font":
                self = .textStyleFontName(textStyle.postscriptName)
            case "fontsize":
                self = .textStyleFontSize(textStyle.fontSize)
            case "identity":
                self = .textStyleIdentity(identity: textStyle.identity, style: .raw)
            case "identity.camelcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .camelcase)
            case "identity.snakecase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .snakecase)
            case let token where token.hasPrefix("color."):
                /// Look for a project color matching the TextStyle's raw color.
                /// If none exists, throw an error for the entire Text Style as "invalid".
                ///
                /// Prism does not support Text Styles with unidentified colors.
                guard let projectColor = colors.first(where: { $0.argbValue == textStyle.color.argbValue }) else {
                    throw Error.missingColorForTextStyle(textStyle)
                }

                self = try Token(rawToken: token, color: projectColor)
            default:
                throw Error.unknownToken(token: rawToken)
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
