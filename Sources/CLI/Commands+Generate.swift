//
//  Commands+Generate.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Commander
import PrismCore
import Yams
import struct ZeplinAPI.Project

// MARK: - Generate command
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

        static var descriptions: [Options.CodingKeys: OptionDescription] {
            return [
                .projectId: .usage("Zeplin Project ID to generate text styles and colors from. Overrides any config files."),
                .templatesPath: .usage("Path to a folder containing *.prism template files. Overrides any config files."),
                .outputPath: .usage("Path to save generated files to. Overrides any config files."),
                .configFile: .usage("Path to YAML configuration file")
            ]
        }

        let projectId: Project.ID?
        let templatesPath: String?
        let outputPath: String?
        let configFile: String?
    }

    static let symbol = "generate"
    static let usage = "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"
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
            
            do {
                config = try decoder.decode(Configuration.self, from: configString)
            } catch {
                throw CommandError.invalidConfiguration(path: configPath)
            }
        }

        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }
        
        guard let projectId = options.projectId ?? config?.projectId else {
            throw CommandError.missingProjectID
        }

        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        let rawTemplatesPath = options.templatesPath ?? config?.templatesPath ?? prismFolder
        let templatesPath = rawTemplatesPath == "/" ? String(rawTemplatesPath.dropLast()) : rawTemplatesPath
        
        guard let rawOutputPath = options.outputPath ?? config?.outputPath else {
            throw CommandError.outputFolderMissing
        }

        let fileManager = FileManager.default
        let outputPath = (rawOutputPath.last == "/" ? String(rawOutputPath.dropLast()) : rawOutputPath)
                            .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)
        
        guard fileManager.folderExists(at: outputPath) else {
            throw CommandError.outputFolderDoesntExist(path: outputPath)
        }
        
        prism.getProjectAssets(for: projectId) { result in
            do {
                let project = try result.get()
                
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
                print("❌ Error: \(err)")
                exit(1)
            }
        }

        sema.wait()
    }
}
