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
                .projectId: .usage("Zeplin Project ID to generate text styles and colors from. Overrides any config files."),
                .templatesPath: .usage("Path to a folder containing *.prism template files. Overrides any config files."),
                .outputPath: .usage("Path to save generated files to. Overrides any config files."),
                .configFile: .usage("Path to YAML configuration file")
            ]
        }

        let projectId: String?
        let templatesPath: String?
        let outputPath: String?
        let configFile: String?
    }

    static var symbol = "generate"
    static var usage = "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"
    static let prismFolder = ".prism"

    static func main(_ options: GenerateCommand.Options) throws {
        var configPath = options.configFile

        let defaultConfigPath = "\(prismFolder)/config.yml"
        let hasDefaultConfig = FileManager.default.fileExists(atPath: defaultConfigPath)
        if configPath == nil && hasDefaultConfig {
            configPath = defaultConfigPath
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
        
        guard let projectId = options.projectId ?? config?.projectId else {
            throw CommandError.missingProjectID
        }

        let prism = PrismAPI(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        let rawTemplatesPath = options.templatesPath ?? config?.templatesPath ?? prismFolder
        let templatesPath = rawTemplatesPath == "/" ? String(rawTemplatesPath.dropLast()) : rawTemplatesPath
        
        guard let rawOutputPath = options.outputPath ?? config?.outputPath else {
            throw CommandError.outputFolderMissing
        }

        let outputPath = rawOutputPath.last == "/" ? String(rawOutputPath.dropLast()) : rawOutputPath

        prism.getProject(id: projectId) { result in
            do {
                let project = try result.get()

                let fileManager = FileManager.default
                let enumerator = fileManager.enumerator(atPath: templatesPath)

                var isFolder: ObjCBool = false
                guard fileManager.fileExists(atPath: templatesPath, isDirectory: &isFolder),
                      isFolder.boolValue else {
                    throw CommandError.templateFolderMissing
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
                print("\(err)")
                exit(1)
            }
        }

        sema.wait()
    }
}

enum CommandError: Swift.Error, CustomStringConvertible {
    case invalidCommand
    case missingProjectID
    case missingToken
    case failedDataConversion
    case templateFolderMissing
    case outputFolderMissing
    case noTemplateFiles
    case missingConfigurationFile(path: String)

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingProjectID:
            return "Missing Zeplin Project ID. Please use the -i flag or provide one in your config.yml"
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        case .templateFolderMissing:
            return "Invalid or missing templates folder. Please provide a valid one via the -t flag or in your config.yml."
        case .outputFolderMissing:
            return "Invalid or missing output folder. Please provide a valid one via the -o flag or in your config.yml."
        case .noTemplateFiles:
            return "Can't find template files (*.prism) in provided folder"
        case .missingConfigurationFile(let path):
            return "Provided configuration path '\(path)' cannot be found"
        }
    }
}
