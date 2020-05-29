//
//  Commands+GenerateAssetCatalog.swift
//  Prism
//
//  Created by Shai Mishali on 29/05/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ArgumentParser
import PrismCore
import Yams
import ZeplinAPI

// MARK: - Generate Asset Catalog command
struct GenerateAssetCatalog: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "asset-catalog",
        abstract: "Generate an Xcode Asset Catalog containing all colors in the specified project"
    )

    @Option(name: .shortAndLong, help: "Zeplin Project ID to generate an asset catalog from. Overrides any config files.")
    var projectId: Project.ID?

    @Option(name: .shortAndLong, help: "Path to save Asset Catalog to.  Overrides any config files.")
    var outputPath: String?

    @Option(name: .shortAndLong, help: "Name of Asset Catalog. Overrides any config files")
    var name: String?

    @Option(name: .shortAndLong, help: "Path to YAML configuration file")
    var configFile: String?

    func run() throws {
        let config = try Configuration(path: configFile)

        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        guard let projectId = projectId ?? config.projectId else {
            throw CommandError.missingProjectID
        }

        let prism = Prism(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        guard let rawOutputPath = outputPath ?? config.assetCatalog.outputPath ?? config.outputPath else {
            throw CommandError.outputFolderMissing
        }

        let fileManager = FileManager.default
        let outputPath = (rawOutputPath.last == "/" ? String(rawOutputPath.dropLast()) : rawOutputPath)
                            .replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path)

        guard fileManager.folderExists(at: outputPath) else {
            throw CommandError.outputFolderDoesntExist(path: outputPath)
        }

        var assetCatalog = name ?? config.assetCatalog.name ?? "Colors.xcassets"
        if !assetCatalog.hasSuffix(".xcassets") {
            assetCatalog.append(".xcassets")
        }

        let assetCatalogPath = "\(outputPath)/\(assetCatalog)"

        prism.getProjectAssets(for: projectId) { result in
            do {
                let project = try result.get()

                // Write base Contents.json
                try FileManager.default.createDirectory(atPath: assetCatalogPath,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)

                try """
                {
                  "info" : {
                    "author" : "prism",
                    "version" : 1
                  }
                }
                """.data(using: .utf8)?.write(to: URL(fileURLWithPath: "\(assetCatalogPath)/Contents.json"))

                // Write individual colors
                for color in project.colors {
                    let colorFolder = "\(assetCatalogPath)/\(color.name).colorset"
                    let colorFileURL = URL(fileURLWithPath: "\(colorFolder)/Contents.json")
                    let colorContent = colorFileContents(for: color)

                    try FileManager.default.createDirectory(atPath: colorFolder,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)

                    try (colorContent.data(using: .utf8) ?? Data()).write(to: colorFileURL)
                }

                sema.signal()
            } catch let err {
                terminate(with: "❌ Error: \(err)")
            }
        }

        sema.wait()
    }
}

// MARK: - Helpers

/// Return the color conetnts of an Asset Catalog Color File
///
/// - parameter color: a `RawColorRepresentable` color
private func colorFileContents<Color: RawColorRepresentable>(for color: Color) -> String {
    """
    {
      "colors" : [
        {
          "color" : {
            "color-space" : "srgb",
            "components" : {
              "red" : "\(color.r)",
              "green" : "\(color.g)",
              "blue" : "\(color.b)",
              "alpha" : "\(color.a)"
            }
          },
          "idiom" : "universal"
        }
      ],
      "info" : {
        "author" : "prism",
        "version" : 1
      }
    }
    """
}
