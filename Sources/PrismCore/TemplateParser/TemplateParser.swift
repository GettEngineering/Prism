//
//  TemplateParser.swift
//  Prism
//
//  Created by Shai Mishali on 23/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ZeplinAPI

/// Provides a mechanism to parse and process Prism-flavored
/// templates into a provided format by extracting tokens
/// and transformations, and resolving and applying them.
///
//
//                                     ┌───────────────┐
//                                   ┌─▶    Tokens     │
//                                   │ │  (resolved)   │
//  ┌─────────────────┐   ┌────────┐ │ └───────┬───────┘   ┌──────────────┐
//  │                 │   │        │ │         │         ┌─▶ Processed    │
//  │ .prism Template ────▶ Parser ├─┘         │         │ │       Output │
//  │                 │   │        │   ┌───────▼───────┐ │ └──────────────┘
//  └─────────────────┘   └────────┘   │Transformations│ │
//                                     │   (applied)   ├─┘
//                                     └───────────────┘

public class TemplateParser {
    let project: ProjectAssets
    let configuration: Configuration?

    /// Initialize a Template Parser object.
    ///
    /// - parameter project: Prism Project.
    /// - parameter configuration: Configuration object (Optional).
    public init(project: ProjectAssets,
                configuration: Configuration? = nil) {
        self.project = project
        self.configuration = configuration
    }

    public func parse(template: String) throws -> String {
        /// Make sure the project doesn't contain any reserved identities.
        /// Otherwise, throw an error.
        var allReservedIdentities = Set<String>()

        if let reservedColors = configuration?.reservedColors {
            let allColorIdentities = Set(project.colors.flatMap { color in
                Project.AssetIdentity.Style.allCases.map { $0.identifier(for: color.identity) }
            })

            let reservedColorsSet = Set(reservedColors)
            let usedReservedColors = reservedColorsSet.intersection(allColorIdentities)

            allReservedIdentities.formUnion(usedReservedColors)
        }

        if let reservedTextStyles = configuration?.reservedTextStyles {
            let allTextStyleIdentities = Set(project.textStyles.flatMap { textStyle in
                Project.AssetIdentity.Style.allCases.map { $0.identifier(for: textStyle.identity) }
            })

            let reservedTextStylesSet = Set(reservedTextStyles)
            let usedReservedTextStyles = reservedTextStylesSet.intersection(allTextStyleIdentities)

            allReservedIdentities.formUnion(usedReservedTextStyles)
        }

        guard allReservedIdentities.isEmpty else {
            throw Error.prohibitedIdentities(identities: allReservedIdentities.joined(separator: ", "))
        }

        /// If everything's OK, try to recrusively parse the provided template.
        return try recursivelyParse(lines: template.components(separatedBy: "\n"))
                    .joined(separator: "\n")
    }

    /// Recursively parse an block of template lines, producing a processed
    /// array of lines are token resolution and transformations.
    ///
    /// If the method finds an iterable directive such as {{% FOR textStyle %}},
    /// it would recursively parse that specific block, providing each text
    /// style (or color) to the method.
    ///
    /// - parameter lines: An array of lines to parse
    /// - parameter color: An optional color. Usually provided within a color loop.
    /// - parameter textStyle: An optional text style. Usually provided within a text style loop.
    ///
    /// - returns: An array of processed lines.
    private func recursivelyParse(lines: [String],
                                  color: Project.Color? = nil,
                                  textStyle: Project.TextStyle? = nil) throws -> [String] {
        var output = [String]()
        var currentLineIdx = 0

        while currentLineIdx < lines.count {
            let currentLine = lines[currentLineIdx]
            let lineLength = currentLine.count

            // Find occurences of FOR loops in the template
            let forRegex = try NSRegularExpression(pattern: #"^(\s{0,})\{\{% FOR (.*?) %\}\}$"#)

            // Detected a FOR loop
            if let forMatch = forRegex.firstMatch(in: currentLine,
                                                  options: .init(),
                                                  range: NSRange(location: 0, length: lineLength)) {
                let nsLine = currentLine as NSString
                let indent = nsLine.substring(with: forMatch.range(at: 1))
                let identifier = nsLine.substring(with: forMatch.range(at: 2))

                // Find matching END
                guard let forEnd = lines[currentLineIdx..<lines.count]
                                    .firstIndex(where: { $0 == "\(indent){{% END \(identifier) %}}" }) else {
                    throw Error.openLoop(identifier: identifier)
                }

                // Recurse over FOR-loop content
                let forBody = Array(lines[currentLineIdx + 1...forEnd - 1])

                switch identifier {
                case "color":
                    var colorLoop = try project.colors
                                               .sorted(by: { $0.identity.name < $1.identity.name })
                                               .reduce(into: [String]()) { result, color in
                        result.append(contentsOf: try recursivelyParse(lines: forBody, color: color))
                    }

                    if colorLoop.last == "" {
                        colorLoop = Array(colorLoop.dropLast())
                    }

                    output.append(contentsOf: colorLoop)
                case "textStyle":
                    var textStyleLoop = try project.textStyles
                                                   .sorted(by: { $0.identity.name < $1.identity.name })
                                                   .reduce(into: [String]()) { result, textStyle in
                        result.append(contentsOf: try recursivelyParse(lines: forBody, textStyle: textStyle))
                    }

                    if textStyleLoop.last == "" {
                        textStyleLoop = Array(textStyleLoop.dropLast())
                    }

                    output.append(contentsOf: textStyleLoop)
                default:
                    throw Error.unknownLoop(identifier: identifier)
                }

                currentLineIdx = forEnd + 1
                continue
            }

            /// Make sure this line has some sort of Token.
            /// Otherwise, simply add it to the output.
            guard currentLine.contains("{{%") else {
                output.append(currentLine)
                currentLineIdx += 1
                continue
            }

            /// The current line has at least a single token that
            /// should be resolved.
            output.append(try resolveTokens(line: currentLine, color: color, textStyle: textStyle))

            currentLineIdx += 1
        }

        return output
    }

    /// Resolve any tokens in the provided line, replacing them
    /// with the correct underlying values.
    ///
    /// - parameter line: A string line.
    /// - parameter color: A color, usually provided if the line is part of a colors loop.
    /// - parameter textStyle: A color, usually provided if the line is part of a text styles loop.
    ///
    /// - returns: Provided line with resolved tokens.
    private func resolveTokens(line: String,
                               color: Project.Color?,
                               textStyle: Project.TextStyle?) throws -> String {
        let lineLength = line.count
        var output = line
        var tokens = [String: String]()

        let tokensRegex = try NSRegularExpression(pattern: #"\{\{%(.*?)%\}\}"#)
        let tokenMatches = tokensRegex.matches(in: line, options: .init(),
                                               range: NSRange(location: 0, length: lineLength))

        for tokenMatch in tokenMatches {
            let fullToken = (line as NSString).substring(with: tokenMatch.range(at: 1))
            let transformations: [Transformation]
            let token: String

            if fullToken.contains("|") {
                let tokenPieces = fullToken.components(separatedBy: "|")
                token = tokenPieces[0]
                transformations = tokenPieces[1...].compactMap(Transformation.init)

                output = output.replacingOccurrences(of: fullToken,
                                                     with: token)
            } else {
                token = fullToken
                transformations = []
            }

            var parsedToken: Token?

            if let color = color {
                parsedToken = Token(rawToken: token, color: color)
            } else if let textStyle = textStyle {
                parsedToken = Token(rawToken: token, textStyle: textStyle, colors: project.colors)
            }

            if let parsedToken = parsedToken {
                tokens[token] = parsedToken.stringValue(transformations: transformations)
            } else {
                throw Error.unknownToken(token: token)
            }
        }

        return tokens.reduce(output) { output, token in
            return output.replacingOccurrences(of: "{{%\(token.key)%}}", with: token.value)
        }
    }
}

extension TemplateParser {
    enum Error: Swift.Error, CustomStringConvertible {
        /// An unknown FOR loop identifier error
        case unknownLoop(identifier: String)

        /// An open FOR loop with no closing END error
        case openLoop(identifier: String)

        /// An unknown template token error
        case unknownToken(token: String)

        /// One or more prohibited identities were used
        case prohibitedIdentities(identities: String)

        var description: String {
            switch self {
            case .unknownLoop(let identifier):
                return "Illegal FOR loop identifier '\(identifier)'"
            case .openLoop(let identifier):
                return "Detected FOR loop '\(identifier)' with no closing END"
            case .unknownToken(let token):
                return "Illegal token in template '\(token)'"
            case .prohibitedIdentities(let identities):
                return "Prohibited identities '\(identities)' can't be used"
            }
        }
    }
}
