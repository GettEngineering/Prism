//
//  Commands.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//

import Foundation
import Commander
import PrismCore

protocol AssetCommandType {
    static var platformUsage: String { get }
    static var projectIdUsage: String { get }
    static var symbol: String { get }
    static var usage: String { get }
}

var generatedHeader: String {
    return """
    /// This file was generated using Prism, Gett's Design System code generator.
    /// https://github.com/gtforge/prism


    """
}

// MARK: - Generate Colors Command
struct GenerateColors: AssetCommandType {
    static var platformUsage = "Platform to generate colors for [iOS, Android]"
    static var projectIdUsage = "Zeplin Project ID to generate colors from"
    static var symbol = "colors"
    static var usage = "Generate and output colors definitions for the provided platform"
}

// MARK: - Generate Text Styles Command
struct GenerateTextStyles: AssetCommandType {
    static var platformUsage = "Platform to generate text styles for [iOS, Android]"
    static var projectIdUsage = "Zeplin Project ID to generate text styles from"
    static var symbol = "textStyles"
    static var usage = "Generate and output text style definitions for the provided platform"
}

// MARK: - Generate to File Command
struct GenerateCommand: CommandRepresentable {
    struct Options: OptionsRepresentable {
        enum CodingKeys: String, CodingKeysRepresentable {
            case platform
            case projectId
            case textStylesPath
            case colorsPath
        }

        static var keys: [Options.CodingKeys: Character] {
            return [.platform: "p",
                    .projectId: "i",
                    .textStylesPath: "t",
                    .colorsPath: "c"]
        }

        static var descriptions: [Options.CodingKeys : OptionDescription] {
            return [
                .platform: .usage("Platform to generate text styles and colors for [iOS, Android]"),
                .projectId: .usage("Zeplin Project ID to generate text styles and colors from"),
                .textStylesPath: .usage("Path to save Text Styles to"),
                .colorsPath: .usage("Path to save Colors to")
            ]
        }

        let platform: Platform
        let projectId: String
        let textStylesPath: String
        let colorsPath: String
    }

    static var symbol = "generate"
    static var usage = "Generate text style and colors definitions and store them to the provided paths"

    static func main(_ options: GenerateCommand.Options) throws {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        let colorsURL = URL(fileURLWithPath: options.colorsPath)
        let textStylesURL = URL(fileURLWithPath: options.textStylesPath)

        prism.getProject(id: options.projectId) { result in
            do {
                let project = try result.get()
                let styleguide = options.platform.styleguide
                let colors = generatedHeader + project.generateColorsFile(from: styleguide)
                let textStyles = generatedHeader + project.generateTextStyleFile(from: styleguide)

                guard let colorsData = colors.data(using: .utf8),
                      let textStylesData = textStyles.data(using: .utf8) else {
                    throw CommandError.failedDataConversion
                }

                try colorsData.write(to: colorsURL)
                try textStylesData.write(to: textStylesURL)

                sema.signal()
            } catch let err {
                print("Failed getting project: \(err)")
                exit(1)
            }
        }

        sema.wait()
    }
}

// MARK: - Generic Console Output Command
struct AssetCommand<Command: AssetCommandType>: CommandRepresentable {
    struct Options: OptionsRepresentable {
        enum CodingKeys: String, CodingKeysRepresentable {
            case platform
            case projectId
        }

        static var keys: [Options.CodingKeys: Character] {
            return [.platform: "p",
                    .projectId: "i"]
        }

        static var descriptions: [Options.CodingKeys : OptionDescription] {
            return [
                .platform: .usage(Command.platformUsage),
                .projectId: .usage(Command.projectIdUsage)
            ]
        }

        let platform: Platform
        let projectId: String
    }

    static var symbol: String {
        return Command.symbol
    }

    static var usage: String {
        return Command.usage
    }

    static func main(_ options: Options) throws {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        guard [GenerateColors.symbol, GenerateTextStyles.symbol].contains(Command.symbol) else {
            throw CommandError.invalidCommand
        }

        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        prism.getProject(id: options.projectId) { result in
            do {
                let project = try result.get()
                let styleguide = options.platform.styleguide

                switch Command.symbol {
                case ColorsCommand.symbol:
                    print(generatedHeader + project.generateColorsFile(from: styleguide))
                case TextStylesCommand.symbol:
                    print(generatedHeader + project.generateTextStyleFile(from: styleguide))
                default:
                    throw CommandError.invalidCommand
                }

                sema.signal()
            } catch let err {
                print("Failed getting project: \(err)")
                exit(1)
            }
        }

        sema.wait()
    }
}

enum CommandError: Swift.Error, CustomStringConvertible {
    case invalidCommand
    case missingToken
    case failedDataConversion

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        }
    }
}

typealias ColorsCommand = AssetCommand<GenerateColors>
typealias TextStylesCommand = AssetCommand<GenerateTextStyles>
