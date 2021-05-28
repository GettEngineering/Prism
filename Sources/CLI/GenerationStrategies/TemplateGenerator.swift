//
//  GenerateTemplates.swift
//  Prism
//
//  Created by Shai Mishali on 17/01/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation
import PrismCore

/// A generation strategy to generate code from a set of templates
struct TemplateGenerator: GenerationStrategy {
    static func generate(
        to path: String,
        command: Generate,
        from assets: Assets,
        with configuration: Configuration?
    ) throws {
        let fileManager = FileManager.default
        let rawTemplatesPath = command.templatesPath ?? configuration?.templatesPath ?? Prism.prismFolder
        let templatesPath = rawTemplatesPath == "/" ? String(rawTemplatesPath.dropLast()) : rawTemplatesPath
        
        let enumerator = fileManager.enumerator(atPath: templatesPath)
        
        var isFolder: ObjCBool = false
        guard fileManager.fileExists(atPath: templatesPath, isDirectory: &isFolder),
              isFolder.boolValue else {
            throw Error.templateFolderMissing
        }
        
        var templateFiles = [String]()
        
        while let templateFile = enumerator?.nextObject() as? String {
            guard !templateFile.hasPrefix("."),
                  templateFile.hasSuffix(".prism") else { continue }
            
            templateFiles.append("\(templatesPath)/\(templateFile)")
        }
        
        guard !templateFiles.isEmpty else {
            throw Error.noTemplateFiles
        }
        
        let baseURL = URL(fileURLWithPath: path)
        let parser = TemplateParser(project: assets, configuration: configuration)
        
        for templateFile in templateFiles {
            let template = try? String(contentsOfFile: templateFile)
            let parsed = try parser.parse(template: template ?? "")
            
            let parsedData = parsed.data(using: .utf8) ?? Data()
            let filePath = templateFile.droppingPrefix(templatesPath + "/").droppingSuffix(".prism")
            let outputURL = baseURL.appendingPathComponent(filePath)
            let outputFolder = outputURL.deletingLastPathComponent()
            
            // Create path to file if doesn't exist
            if !fileManager.fileExists(atPath: outputFolder.path) {
                try fileManager.createDirectory(at: outputFolder,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            }
            
            try parsedData.write(to: outputURL)
        }
    }
}

extension TemplateGenerator {
    enum Error: Swift.Error, CustomStringConvertible {
        case templateFolderMissing
        case noTemplateFiles
        
        var description: String {
            switch self {
            case .templateFolderMissing:
                return "Invalid or missing templates folder. Please provide a valid one via the -t flag or in your config.yml."
            case .noTemplateFiles:
                return "Can't find template files (*.prism) in provided folder"
            }
        }
    }
}
