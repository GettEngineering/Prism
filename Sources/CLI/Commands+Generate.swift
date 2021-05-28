//
//  Commands+Generate.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ArgumentParser
import PrismCore
import Yams
import ZeplinAPI

// MARK: - Generate command
struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"
    )
    
    @Option(name: .shortAndLong, help: "Zeplin Project ID to generate text styles and colors from. Overrides any config files.")
    var projectId: Project.ID?

    @Option(name: .shortAndLong, help: "Zeplin Styleguide ID to generate text styles and colors from. Overrides any config files.")
    var styleguideId: Styleguide.ID?
    
    @Option(name: .shortAndLong, help: "Path to a folder containing *.prism template files. Overrides any config files.")
    var templatesPath: String?
    
    @Option(name: .shortAndLong, help: "Path to save generated files to. Overrides any config files.")
    var outputPath: String?
    
    @Option(name: .shortAndLong, help: "Path to YAML configuration file")
    var configFile: String?
    
    func run() throws {
        var configPath = configFile

        let defaultConfigPath = "\(Prism.prismFolder)/config.yml"
        let hasDefaultConfig = FileManager.default.fileExists(atPath: defaultConfigPath)
        if configPath == nil && hasDefaultConfig {
            configPath = defaultConfigPath
        }

        // Configuration, if applicable
        //
        // It is valid to have _no_ configuration file, as long as the
        // consumer manually specified runtime flags for everythiing.
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

        let ownerProject = (projectId ?? config?.projectId).map { AssetOwner.project(id: $0) }
        let ownerStyleguide = (styleguideId ?? config?.styleguideId).map { AssetOwner.styleguide(id: $0) }

        // Make sure we have either a project or a styleguide
        guard let owner = ownerProject ?? ownerStyleguide else {
            throw CommandError.missingOwner
        }

        // Exclusive owner check (you can only have either, but not both)
        if ownerProject != nil && ownerStyleguide != nil {
            throw CommandError.conflictingOwner
        }
        
        let fileManager = FileManager.default
        
        guard let rawOutputPath = outputPath ?? config?.outputPath else {
            throw CommandError.outputFolderMissing
        }
        
        let outputPath = (rawOutputPath.last == "/" ? String(rawOutputPath.dropLast()) : rawOutputPath)
            .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)
        
        guard fileManager.folderExists(at: outputPath) else {
            throw CommandError.outputFolderDoesntExist(path: outputPath)
        }
        
        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)
        
        prism.getAssets(for: owner) { result in
            do {
                let assets = try result.get()
                let strategies = [TemplateGenerator.self, AssetCatalogGenerator.self] as [GenerationStrategy.Type]
                
                for strategy in strategies {
                    try strategy.generate(to: outputPath,
                                          command: self,
                                          from: assets,
                                          with: config)
                }
            } catch let err {
                terminate(with: "❌ Error: \(err)")
            }
            
            sema.signal()
        }

        sema.wait()
    }
}
