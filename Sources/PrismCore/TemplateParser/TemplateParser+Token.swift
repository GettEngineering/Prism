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
        // Color
        case colorRed(Int)
        case colorGreen(Int)
        case colorBlue(Int)
        case colorAlpha(Float)
        case colorARGB(String)
        case colorRGB(String)
        case colorIdentity(identity: Project.AssetIdentity,
                           style: Project.AssetIdentity.Style)

        // Text Style
        case textStyleFontName(String)
        case textStyleFontSize(Float)
        case textStyleIdentity(identity: Project.AssetIdentity,
                               style: Project.AssetIdentity.Style)
        case textStyleFontWeight(Int)
        case textStyleFontStyle(String)
        case textStyleFontStretch(Float)
        case textStyleAlignment(String?)
        case textStyleLineHeight(Float?)
        case textStyleLetterSpacing(Float?)

        // Spacing
        case spacingIdentity(identity: Project.AssetIdentity,
                             style: Project.AssetIdentity.Style)
        case spacingValue(Float)
        
        /// Parse a raw color token, such as "color.r", into its
        /// appropriate Token case (e.g. `.colorRed(value)` in this case).
        ///
        /// - parameter rawColorToken: A raw color token, e.g. `color.*`
        /// - parameter color: A project color with an asset identity
        init(rawColorToken: String, color: Color) throws {
            let cleanToken = rawColorToken.lowercased()
                                          .trimmingCharacters(in: .whitespaces)
            guard cleanToken.hasPrefix("color.") else {
                throw Error.unknownToken(token: rawColorToken)
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
            case "identity.kebabcase":
                self = .colorIdentity(identity: color.identity, style: .kebabcase)
            case "identity.pascalcase":
                self = .colorIdentity(identity: color.identity, style: .pascalcase)
            default:
                throw Error.unknownToken(token: rawColorToken)
            }
        }

        /// Parse a raw text style token, such as "textStyle.fontName", into its
        /// appropriate Token case (e.g. `.textStyleFontName(value)` in this case).
        ///
        /// - parameter rawTextStyleToken: A raw text style token, e.g. `textStyle.*`
        /// - parameter textStyle: A project text style with an asset identity
        /// - parameter color: A project color with an asset identity
        init(rawTextStyleToken: String, textStyle: TextStyle, colors: [Color]) throws {
            let cleanToken = rawTextStyleToken.lowercased()
                                              .trimmingCharacters(in: .whitespaces)
            guard cleanToken.hasPrefix("textstyle.") else {
                throw Error.unknownToken(token: rawTextStyleToken)
            }
            
            let textStyleToken = String(cleanToken.dropFirst(10))

            switch textStyleToken {
            case "fontname",
                 "font":
                self = .textStyleFontName(textStyle.postscriptName)
            case "fontsize":
                self = .textStyleFontSize(textStyle.fontSize)
            case "fontweight":
                self = .textStyleFontWeight(textStyle.fontWeight)
            case "fontstyle":
                self = .textStyleFontStyle(textStyle.fontStyle)
            case "fontstretch":
                self = .textStyleFontStretch(textStyle.fontStretch)
            case "identity":
                self = .textStyleIdentity(identity: textStyle.identity, style: .raw)
            case "identity.camelcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .camelcase)
            case "identity.snakecase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .snakecase)
            case "identity.kebabcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .kebabcase)
            case "identity.pascalcase":
                self = .textStyleIdentity(identity: textStyle.identity, style: .pascalcase)
            case let token where token.hasPrefix("color."):
                // If a color token is used for a text style with no color,
                // we throw an error
                guard let textStyleColor = textStyle.color else {
                    throw Error.missingColorForTextStyle(textStyle)
                }

                // Look for a project color matching the Text Style's raw color.
                // If none exists, throw an error for the entire Text Style as "invalid".
                //
                /// Prism does not support Text Styles with unidentified colors.
                guard let projectColor = colors.first(where: { $0.argbValue == textStyleColor.argbValue }) else {
                    throw Error.missingColorForTextStyle(textStyle)
                }

                self = try Token(rawColorToken: token, color: projectColor)
            case "alignment":
                self = .textStyleAlignment(textStyle.textAlign?.rawValue)
            case "lineheight":
                self = .textStyleLineHeight(textStyle.lineHeight)
            case "letterspacing":
                self = .textStyleLetterSpacing(textStyle.letterSpacing)
            default:
                throw Error.unknownToken(token: rawTextStyleToken)
            }
        }

        /// Parse a raw spacing token, such as "spacing.value", into its
        /// appropriate Token case (e.g. `.spacingValue(value)` in this case).
        ///
        /// - parameter rawSpacingToken: A raw text style token, e.g. `spacing.*`
        /// - parameter spacing: A spacing entity
        init(rawSpacingToken: String, spacing: Spacing) throws {
            let cleanToken = rawSpacingToken.lowercased()
                                            .trimmingCharacters(in: .whitespaces)
            guard cleanToken.hasPrefix("spacing.") else {
                throw Error.unknownToken(token: rawSpacingToken)
            }

            let spacingToken = String(cleanToken.dropFirst(8))

            switch spacingToken {
            case "identity":
                self = .spacingIdentity(identity: spacing.identity, style: .raw)
            case "identity.camelcase":
                self = .spacingIdentity(identity: spacing.identity, style: .camelcase)
            case "identity.snakecase":
                self = .spacingIdentity(identity: spacing.identity, style: .snakecase)
            case "identity.kebabcase":
                self = .spacingIdentity(identity: spacing.identity, style: .kebabcase)
            case "identity.pascalcase":
                self = .spacingIdentity(identity: spacing.identity, style: .pascalcase)
            case "value":
                self = .spacingValue(spacing.value)
            default:
                throw Error.unknownToken(token: rawSpacingToken)
            }
        }

        /// Determine if a provided token is a valid loop position token
        /// e.g. "isFirst", "isLast" based on the provided `LoopPosition`
        ///
        /// - parameter token: Raw string token
        /// - parameter position: Loop position object
        /// - parameter base: Base asset, e.g. "color", "textStyle", "spacing"
        ///
        /// - returns: A tuple where the first boolean indicates this is a valid position token,
        ///            and the second indicates it correctly matches the provided block position
        static func isValidPositionToken(_ token: String,
                                         for position: Block.LoopPosition,
                                         base: String) -> (isValid: Bool, doesMatch: Bool) {
            let pieces = token.lowercased().components(separatedBy: ".")
            guard pieces.count == 2,
                  pieces[0] == base.lowercased() else { return (false, false) }

            let rawPosition = pieces[1]
            let isValid = rawPosition == "isfirst" || rawPosition == "islast"

            switch (rawPosition, position) {
            case ("isfirst", .first), ("isfirst", .single):
                return (isValid, true)
            case ("islast", .last), ("islast", .single):
                return (isValid, true)
            default:
                return (isValid, false)
            }
        }

        /// Process the current token, while applying the provided
        /// set of transformations.
        ///
        /// - parameter transformations: An array of Transofmration functions.
        ///
        /// - returns: A processed token value.
        func stringValue(transformations: [Transformation]) -> String? {
            var baseString: String?
            switch self {
            case let .colorIdentity(identity, style),
                 let .textStyleIdentity(identity, style),
                 let .spacingIdentity(identity, style):
                baseString = style.identifier(for: identity)
            case .colorAlpha(let alpha):
                baseString = String(format: "%.2f", alpha)
            case .colorRed(let c),
                 .colorGreen(let c),
                 .colorBlue(let c):
                baseString = "\(c)"
            case .colorARGB(let hex),
                 .colorRGB(let hex):
                baseString = hex
            case .textStyleFontName(let name):
                baseString = name
            case .textStyleFontSize(let size):
                baseString = size.roundedToNearest()
            case .textStyleFontWeight(let weight):
                baseString = "\(weight)"
            case .textStyleFontStyle(let style):
                baseString = "\(style)"
            case .textStyleFontStretch(let stretch):
                baseString = "\(stretch)"
            case .textStyleAlignment(let alignment):
                baseString = alignment
            case .textStyleLetterSpacing(let spacing):
                if let spacing = spacing {
                    baseString = spacing.roundedToNearest()
                }
            case .textStyleLineHeight(let height):
                if let height = height {
                    baseString = height.roundedToNearest()
                }
            case .spacingValue(let value):
                baseString = value.roundedToNearest()
            }

            guard let output = baseString else { return nil }
            return transformations.reduce(into: output) { $0 = $1.apply(to: $0) }
        }
    }
}

// MARK: - Private Helpers
private extension Float {
    /// Round the Float to the nearest 2 floating points
    func roundedToNearest() -> String {
        let value = (self * 100).rounded(.toNearestOrEven) / 100

        let int = Int(value)
        if Float(int) == value {
            return "\(int)"
        } else {
            return "\(value)"
        }
    }
}
