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

struct GenerateColors: AssetCommandType {
    static var platformUsage = "Platform to generate colors for [iOS, Android]"
    static var projectIdUsage = "Zeplin Project ID to generate colors from"
    static var symbol = "colors"
    static var usage = "Generate and output colors definitions for the provided platform"
}

struct GenerateTextStyles: AssetCommandType {
    static var platformUsage = "Platform to generate text styles for [iOS, Android]"
    static var projectIdUsage = "Zeplin Project ID to generate text styles from"
    static var symbol = "textStyles"
    static var usage = "Generate and output text style definitions for the provided platform"
}

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
            throw Error.missingToken
        }

        guard [GenerateColors.symbol, GenerateTextStyles.symbol].contains(Command.symbol) else {
            throw Error.invalidCommand
        }

        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        prism.getProject(id: options.projectId) { result in
            do {
                let project = try result.get()
                let styleguide = options.platform.styleguide

                switch Command.symbol {
                case ColorsCommand.symbol:
                    print(project.generateColorsFile(from: styleguide))
                case TextStylesCommand.symbol:
                    print(project.generateTextStyleFile(from: styleguide))
                default:
                    throw Error.invalidCommand
                }

                sema.signal()
            } catch let err {
                print("Failed getting project: \(err)")
                exit(1)
            }
        }

        sema.wait()
    }

    enum Error: Swift.Error {
        case invalidCommand
        case missingToken
    }
}

typealias ColorsCommand = AssetCommand<GenerateColors>
typealias TextStylesCommand = AssetCommand<GenerateTextStyles>
