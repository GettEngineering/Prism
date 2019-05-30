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
        case colorIdentity(String, Platform)

        /// Text Style
        case textStyleFontName(String)
        case textStyleFontSize(Float)
        case textStyleIdentity(String, Platform)
        case textStyleColorIdentity(String, Platform)

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
            case let .colorIdentity(_, platform):
                return "color.identity.\(platform.rawValue)"
            case .textStyleFontName:
                return "textStyle.fontName"
            case .textStyleFontSize:
                return "textStyle.fontSize"
            case let .textStyleIdentity(_, platform):
                return "textStyle.identity.\(platform.rawValue)"
            case let .textStyleColorIdentity(_, platform):
                return "textStyle.color.identity.\(platform.rawValue)"
            }
        }

        /// Parse a raw color token, such as "color.r", into its
        /// appropriate Token case (e.g. `.colorRed(value)` in this case).
        init?(rawToken: String, color: Prism.Project.Color) {
            switch rawToken {
            case "color.r":
                self = .colorRed(color.r)
            case "color.g":
                self = .colorGreen(color.g)
            case "color.b":
                self = .colorBlue(color.b)
            case "color.a":
                self = .colorAlpha(color.a)
            case "color.identity.iOS":
                self = .colorIdentity(color.identity.iOS, .iOS)
            case "color.identity.android":
                self = .colorIdentity(color.identity.android, .android)
            default:
                return nil
            }
        }

        /// Parse a raw text style token, such as "textStyle.fontName", into its
        /// appropriate Token case (e.g. `.textStyleFontName(value)` in this case).
        init?(rawToken: String, textStyle: Prism.Project.TextStyle, colors: [Prism.Project.Color]) {
            switch rawToken {
            case "textStyle.fontName":
                self = .textStyleFontName(textStyle.fontFace)
            case "textStyle.fontSize":
                self = .textStyleFontSize(textStyle.fontSize)
            case "textStyle.identity.iOS":
                self = .textStyleIdentity(textStyle.identity.iOS, .iOS)
            case "textStyle.identity.android":
                self = .textStyleIdentity(textStyle.identity.android, .android)
            case "textStyle.color.identity.iOS":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .textStyleColorIdentity(identity.iOS, .iOS)
            case "textStyle.color.identity.android":
                guard let identity = colors.identity(matching: textStyle.color) else {
                    return nil
                }

                self = .textStyleColorIdentity(identity.android, .android)
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
            case .colorIdentity(let id, _),
                 .textStyleIdentity(let id, _),
                 .textStyleColorIdentity(let id, _):
                baseString = id
            case .textStyleFontName(let name):
                baseString = name
            case .textStyleFontSize(let size):
                baseString = "\(size)"
            }

            return transformations.reduce(into: baseString) { $0 = $1.apply(to: $0) }
        }
    }
}
