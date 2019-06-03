//
//  Commands.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//

import Foundation
import Commander
import PrismCore
import Yams

// MARK: - Generate to File Command
struct GenerateCommand: CommandRepresentable {
    struct Options: OptionsRepresentable {
        enum CodingKeys: String, CodingKeysRepresentable {
            case projectId
            case templatesPath
            case outputPath
            case configFile
        }

        static var keys: [Options.CodingKeys: Character] {
            return [.projectId: "i",
                    .templatesPath: "t",
                    .outputPath: "o",
                    .configFile: "c"]
        }

        static var descriptions: [Options.CodingKeys : OptionDescription] {
            return [
                .projectId: .usage("Zeplin Project ID to generate text styles and colors from"),
                .templatesPath: .usage("Path to a folder containing *.prism template files"),
                .outputPath: .usage("Path to save generated files to"),
                .configFile: .usage("Path to YAML configuration file")
            ]
        }

        let projectId: String
        let templatesPath: String
        let outputPath: String
        let configFile: String?
    }

    static var symbol = "generate"
    static var usage = "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"

    static func main(_ options: GenerateCommand.Options) throws {
        var configPath = options.configFile

        let hasLocalConfig = FileManager.default.fileExists(atPath: "prism.yml")
        if configPath == nil && hasLocalConfig {
            configPath = "prism.yml"
        }

        // Configuration
        var config: Configuration?
        if let configPath = configPath {
            guard let configData = FileManager.default.contents(atPath: configPath),
                  let configString = String(data: configData, encoding: .utf8) else {
                throw CommandError.missingConfigurationFile(path: configPath)
            }

            let decoder = YAMLDecoder()
            config = try? decoder.decode(Configuration.self, from: configString)
        }

        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        let prism = PrismAPI(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        let templatesPath = options.templatesPath.last == "/" ? String(options.templatesPath.dropLast()) : options.templatesPath
        let outputPath = options.outputPath.last == "/" ? String(options.outputPath.dropLast()) : options.outputPath

        prism.getProject(id: options.projectId) { result in
            do {
                let project = try result.get()

                let fileManager = FileManager.default
                let enumerator = fileManager.enumerator(atPath: templatesPath)

                guard fileManager.fileExists(atPath: templatesPath) else {
                    throw CommandError.templateFolderMissing(path: templatesPath)
                }

                var templateFiles = [String]()

                while let templateFile = enumerator?.nextObject() as? String {
                    guard !templateFile.hasPrefix("."),
                          templateFile.hasSuffix(".prism") else { continue }

                    templateFiles.append("\(templatesPath)/\(templateFile)")
                }

                guard !templateFiles.isEmpty else {
                    throw CommandError.noTemplateFiles
                }

                let parser = TemplateParser(project: project, configuration: config)

                for templateFile in templateFiles {
                    let template = try? String(contentsOfFile: templateFile)
                    let parsed = try parser.parse(template: template ?? "")

                    let parsedData = parsed.data(using: .utf8) ?? Data()
                    let filename = templateFile.components(separatedBy: "/").last ?? ""
                    let outFile = String(filename.dropLast(6))
                    let outPath = "\(outputPath)/\(outFile)"

                    try parsedData.write(to: URL(fileURLWithPath: outPath))
                }

                sema.signal()
            } catch let err {
                print("[ERROR] \(err)")
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
    case templateFolderMissing(path: String)
    case noTemplateFiles
    case missingConfigurationFile(path: String)

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        case .templateFolderMissing(let path):
            return "The provided template folder doesn't exist: \(path)"
        case .noTemplateFiles:
            return "Can't find template files (*.prism) in provided folder"
        case .missingConfigurationFile(let path):
            return "Provided configuration path '\(path)' cannot be found"
        }
    }
}
