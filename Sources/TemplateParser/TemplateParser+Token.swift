//
//  TemplateParser+Token.swift
//  Prism
//
//  Created by Shai Mishali on 29/05/2019.
//

import Foundation

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
        case colorIdentity(identity: Project.AssetIdentity,
                           style: Project.AssetIdentity.Style)

        /// Text Style
        case textStyleFontName(String)
        case textStyleFontSize(Float)
        case textStyleIdentity(identity: Project.AssetIdentity,
                               style: Project.AssetIdentity.Style)
        case textStyleColorIdentity(identity: Project.AssetIdentity,
                                    style: Project.AssetIdentity.Style)

        /// A string token representation, same as the one used in
        /// a .prism template file.
        var stringToken: String {
            switch self {
            case .colorRed:
                return "color.r"
            case .colorGreen:
                return "color.g"
            case .colorBlue:
                return "color.b"
            case .colorAlpha:
                return "color.a"
            case .colorARGB:
                return "color.argb"
            case let .colorIdentity(_, platform):
                return "color.identity.\(platform.rawValue)"
            case .textStyleFontName:
                return "textStyle.fontName"
            case .textStyleFontSize:
                return "textStyle.fontSize"
            case let .textStyleIdentity(_, style):
                return "textStyle.identity.\(style.rawValue)"
            case let .textStyleColorIdentity(_, style):
                return "textStyle.color.identity.\(style.rawValue)"
            }
        }

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
                self = .textStyleFontName(textStyle.fontFace)
            case "textStyle.fontSize":
                self = .textStyleFontSize(textStyle.fontSize)
            case "textStyle.identity.camelcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .camelcase)
            case "textStyle.identity.snakecase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .snakecase)
            case "textStyle.color.identity.camelcase":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .textStyleColorIdentity(identity: identity, style: .camelcase)
            case "textStyle.color.identity.snakecase":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .textStyleColorIdentity(identity: identity, style: .snakecase)
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
            case .colorARGB(let hex):
                baseString = hex
            case let .colorIdentity(identity, style),
                 let .textStyleIdentity(identity, style),
                 let .textStyleColorIdentity(identity, style):
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
