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

    public func parse(template: String) -> String {
        return recursivelyParse(lines: template.components(separatedBy: "\n"))
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
                                  textStyle: Prism.Project.TextStyle? = nil) -> [String] {
        var output = [String]()
        var currentLineIdx = 0

        while currentLineIdx < lines.count {
            let currentLine = lines[currentLineIdx]
            let lineLength = currentLine.count

            do {
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
                        fatalError("Can't find FOR closing for \(identifier)")
                    }

                    // Recurse over FOR-loop content
                    let forBody = Array(lines[currentLineIdx + 1...forEnd - 1])

                    switch identifier {
                    case "color":
                        let colorLoop = project.colors
                                               .sorted(by: { $0.identity.iOS < $1.identity.iOS })
                                               .reduce(into: [String]()) { result, color in
                            result.append(contentsOf: recursivelyParse(lines: forBody, color: color))
                        }

                        output.append(contentsOf: colorLoop)
                    case "textStyle":
                        let textStyleLoop = project.textStyles
                                                   .sorted(by: { $0.identity.iOS < $1.identity.iOS })
                                                   .reduce(into: [String]()) { result, textStyle in
                            result.append(contentsOf: recursivelyParse(lines: forBody, textStyle: textStyle))
                        }

                        output.append(contentsOf: textStyleLoop)
                    default:
                        break
                    }

                    currentLineIdx = forEnd + 1
                    continue
                }
            } catch let err {
                fatalError("Failed matching: \(err)")
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
            output.append(resolveTokens(line: currentLine, color: color, textStyle: textStyle))

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
                               textStyle: Prism.Project.TextStyle?) -> String {
        let lineLength = line.count
        var output = line
        var tokens = [String: String]()

        do {
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
                    parsedToken = Token(rawToken: token, textStyle: textStyle, project: project)
                }

                if let token = parsedToken {
                    tokens[token.stringToken] = token.stringValue(transformations: transformations)
                }
            }
        } catch let err {
            fatalError("Unexpected failure: \(err)")
        }

        return tokens.reduce(output) { output, token in
            return output.replacingOccurrences(of: "{{%\(token.key)%}}", with: token.value)
        }
    }
}
