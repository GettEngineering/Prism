//
//  TemplateParser.swift
//  Prism
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation

/// Provides a mechanism to parse and process Prism-flavored
/// templates into a provided format by extracting tokens
/// and transformations, and resolving and applying them.
///
///                                    ┌───────────────┐
///                                  ┌─▶    Tokens     │
///                                  │ │  (resolved)   │
/// ┌─────────────────┐   ┌────────┐ │ └───────┬───────┘   ┌──────────────┐
/// │                 │   │        │ │         │         ┌─▶ Processed    │
/// │ .prism Template ────▶ Parser ├─┘         │         │ │       Output │
/// │                 │   │        │   ┌───────▼───────┐ │ └──────────────┘
/// └─────────────────┘   └────────┘   │Transformations│ │
///                                    │   (applied)   ├─┘
///                                    └───────────────┘
public class TemplateParser {
    let project: Prism.Project

    public init(project: Prism.Project) {
        self.project = project
    }

    public func parse(template: String) throws -> String {
        return try recursivelyParse(lines: template.components(separatedBy: "\n"))
                    .joined(separator: "\n")
    }

    /// Recursively parse an block of template lines, producing a processed
    /// array of lines are token resolution and transformations.
    ///
    /// If the method finds an iterable directive such as {{% FOR textStyle %}},
    /// it would recursively parse that specific block, providing each text
    /// style (or color) to the method.
    private func recursivelyParse(lines: [String],
                                  color: Prism.Project.Color? = nil,
                                  textStyle: Prism.Project.TextStyle? = nil) throws -> [String] {
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
                    let colorLoop = try project.colors
                                               .sorted(by: { $0.identity.name < $1.identity.name })
                                               .reduce(into: [String]()) { result, color in
                        result.append(contentsOf: try recursivelyParse(lines: forBody, color: color))
                    }

                    output.append(contentsOf: colorLoop)
                case "textStyle":
                    let textStyleLoop = try project.textStyles
                                                   .sorted(by: { $0.identity.name < $1.identity.name })
                                                   .reduce(into: [String]()) { result, textStyle in
                        result.append(contentsOf: try recursivelyParse(lines: forBody, textStyle: textStyle))
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
    /// - parameter line: A string line
    /// - parameter color: A color, usually provided if the line is part of a colors loop.
    /// - parameter textStyle: A color, usually provided if the line is part of a text styles loop.
    ///
    /// - returns: Provided line with resolved tokens
    private func resolveTokens(line: String,
                               color: Prism.Project.Color?,
                               textStyle: Prism.Project.TextStyle?) throws -> String {
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

            if let token = parsedToken {
                tokens[token.stringToken] = token.stringValue(transformations: transformations)
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
    enum Error: Swift.Error {
        case unknownLoop(identifier: String)
        case openLoop(identifier: String)
        case unknownToken(token: String)

        var localizedDescription: String {
            switch self {
            case .unknownLoop(let identifier):
                return "Illegal FOR loop identifier '\(identifier)'"
            case .openLoop(let identifier):
                return "Detected FOR loop '\(identifier)' with no closing END"
            case .unknownToken(let token):
                return "Illegal token in template '\(token)'"
            }
        }
    }
}
