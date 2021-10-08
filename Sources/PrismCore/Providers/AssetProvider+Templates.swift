//
//  File.swift
//  
//
//  Created by Shai Mishali on 04/10/2021.
//

import Foundation
import ProviderCore

extension AssetProviding {
    /// Parse all available user templates with the provided assets and configuration.
    /// Then, generate the resulting code and store it in the provided `outputPath`.
    ///
    /// - parameter assets: Provider assets, such as colors and text styles
    /// - parameter configuration: The provider's configuration
    static func parseTemplates(
        with assets: Assets,
        configuration: ProviderCore.Configuration<Self>
    ) throws {
        // Fetch all templates
        let rawTemplatesPath = configuration.templatesPath ?? ".prism"
        let templatesPath = rawTemplatesPath == "/" ? String(rawTemplatesPath.dropLast()) : rawTemplatesPath

        guard let rawOutputPath = configuration.outputPath else {
            throw TemplateParsingError.outputFolderMissing
        }

        let fileManager = FileManager.default
        let outputPath = (rawOutputPath.last == "/" ? String(rawOutputPath.dropLast()) : rawOutputPath)
                            .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)

        guard fileManager.folderExists(at: outputPath) else {
            throw TemplateParsingError.outputFolderDoesntExist(path: outputPath)
        }

        let enumerator = fileManager.enumerator(atPath: templatesPath)

        var isFolder: ObjCBool = false
        guard fileManager.fileExists(atPath: templatesPath, isDirectory: &isFolder),
              isFolder.boolValue else {
            throw TemplateParsingError.templateFolderMissing
        }

        var templateFiles = [String]()

        while let templateFile = enumerator?.nextObject() as? String {
            guard !templateFile.hasPrefix("."),
                  templateFile.hasSuffix(".prism") else { continue }

            templateFiles.append("\(templatesPath)/\(templateFile)")
        }

        guard !templateFiles.isEmpty else {
            throw TemplateParsingError.noTemplateFiles
        }

        // Parse! 🚢
        let parser = TemplateParser(assets: assets, configuration: configuration)
        let baseURL = URL(fileURLWithPath: outputPath)

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

enum TemplateParsingError: Swift.Error, CustomStringConvertible {
    case templateFolderMissing
    case outputFolderMissing
    case outputFolderDoesntExist(path: String)
    case noTemplateFiles

    var description: String {
        switch self {
        case .templateFolderMissing:
            return "Invalid or missing templates folder. Please provide a valid one in your config.yml."
        case .outputFolderMissing:
            return "Invalid or missing output folder. Please provide a valid one via the -o flag or in your config.yml."
        case .outputFolderDoesntExist(let path):
            return "Provided output path at '\(path)' doesn't exist"
        case .noTemplateFiles:
            return "Can't find template files (*.prism) in provided folder"
        }
    }
}
