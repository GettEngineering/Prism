//
//  TemplateParser.swift
//  PrismCore
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation

public class TemplateParser {
    let project: Prism.Project

    public init(project: Prism.Project) {
        self.project = project
    }

    public func parse(template: String) -> String {
        return internalParse(lines: template.components(separatedBy: "\n"))
                 .joined(separator: "\n")
    }

    private func internalParse(lines: [String],
                               color: Prism.Project.Color? = nil,
                               textStyle: Prism.Project.TextStyle? = nil) -> [String] {
        var output = [String]()
        var currentLineIdx = 0

        while currentLineIdx < lines.count {
            let currentLine = lines[currentLineIdx]
            let lineLength = currentLine.count

            do {
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
                            result.append(contentsOf: internalParse(lines: forBody, color: color))
                        }

                        output.append(contentsOf: colorLoop)
                    case "textStyle":
                        let textStyleLoop = project.textStyles
                                                   .sorted(by: { $0.identity.iOS < $1.identity.iOS })
                                                   .reduce(into: [String]()) { result, textStyle in
                            result.append(contentsOf: internalParse(lines: forBody, textStyle: textStyle))
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

            guard currentLine.contains("{{%") else {
                output.append(currentLine)
                currentLineIdx += 1
                continue
            }

            output.append(applyTokens(line: currentLine, color: color, textStyle: textStyle))

            currentLineIdx += 1
        }

        return output
    }

    private func applyTokens(line: String,
                             color: Prism.Project.Color?,
                             textStyle: Prism.Project.TextStyle?) -> String {
        let lineLength = line.count
        var output = line

        do {
            let tokensRegex = try NSRegularExpression(pattern: #"\{\{%(.*?)%\}\}"#)
            let tokenMatches = tokensRegex.matches(in: line, options: .init(),
                                                   range: NSRange(location: 0, length: lineLength))

            var tokens = [String: String]()

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
                }

                if let textStyle = textStyle {
                    parsedToken = Token(rawToken: token, textStyle: textStyle, project: project)
                }

                if let token = parsedToken {
                    tokens[token.stringToken] = token.stringValue(transformations: transformations)
                    output = tokens.reduce(into: output) { output, token in
                        output = output.replacingOccurrences(of: "{{%\(token.key)%}}", with: token.value)
                    }
                }
            }
        } catch let err {
            fatalError("Unexpected failure: \(err)")
        }

        return output
    }
}

extension TemplateParser {
    enum Token {
        /// Color
        case colorRed(Int)
        case colorGreen(Int)
        case colorBlue(Int)
        case colorAlpha(Double)
        case colorIdentity(String, Prism.Project.Platform)

        /// Text Style
        case textStyleFontName(String)
        case textStyleFontSize(Float)
        case textStyleIdentity(String, Prism.Project.Platform)
        case textStyleColorIdentity(String, Prism.Project.Platform)
        case textStyleColor(String, Prism.Project.Platform)

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
            case let .textStyleColorIdentity(_, platform),
                 let .textStyleColor(_, platform):
                return "textStyle.color.identity.\(platform.rawValue)"
            }
        }

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

        init?(rawToken: String, textStyle: Prism.Project.TextStyle, project: Prism.Project) {
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
                guard let identity = project.colorIdentity(for: textStyle.color) else {
                    self = .textStyleColor("UIColor(r: \(textStyle.color.r), g: \(textStyle.color.g), b: \(textStyle.color.b), alpha: \(textStyle.color.a))", .iOS)
                    return
                }

                self = .textStyleColorIdentity(identity.iOS, .iOS)
            case "textStyle.color.identity.android":
                guard let identity = project.colorIdentity(for: textStyle.color) else {
                    self = .textStyleColor(textStyle.color.argbValue, .iOS)
                    return
                }

                self = .colorIdentity(identity.android, .android)
            default:
                return nil
            }
        }

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
                 .textStyleColorIdentity(let id, _),
                 .textStyleColor(let id, _):
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

extension TemplateParser {
    enum Transformation {
        case lowercase
        case uppercase
        case replace(String, String)

        init?(rawValue: String) {
            let fullRange = NSRange(location: 0, length: rawValue.count)
            let nsValue = rawValue as NSString
            let pattern = #"^(.*?)(\((.*?)\)){0,1}$"#

            do {
                let regex = try NSRegularExpression(pattern: pattern)
                guard let match = regex.matches(in: rawValue, options: [], range: fullRange).first else {
                    return nil
                }

                let action = nsValue.substring(with: match.range(at: 1))
                let params: [String]

                if match.range(at: 3).location == NSNotFound {
                    params = []
                } else {
                    params = nsValue.substring(with: match.range(at: 3))
                                    .components(separatedBy: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                }

                switch (action, params.count) {
                case ("lowercase", 0):
                    self = .lowercase
                case ("uppercase", 0):
                    self = .uppercase
                case ("replace", 2):
                    self = .replace(params[0], params[1])
                default:
                    return nil
                }
            } catch let err {
                fatalError("Unexpected failure: \(err)")
                return nil
            }
        }

        func apply(to string: String) -> String {
            switch self {
            case .lowercase:
                return string.lowercased()
            case .uppercase:
                return string.uppercased()
            case let .replace(of, with):
                return string.replacingOccurrences(of: of, with: with)
            }
        }
    }
}
