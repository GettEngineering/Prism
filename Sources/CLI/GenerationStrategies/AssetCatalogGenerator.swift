//
//  AssetCatalogGenerator.swift
//  Prism
//
//  Created by Shai Mishali on 17/01/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation
import PrismCore
import ZeplinAPI

/// A generation strategy to generate an asset catalog with the
/// projects colors
struct AssetCatalogGenerator: GenerationStrategy {
    static func generate(to path: String,
                         command: Generate,
                         from assets: Assets,
                         with configuration: Configuration?) throws {
        // Generate an asset catalog only if a proper configuration was provided
        guard var assetCatalog = configuration?.assetCatalog?.name else {
            return
        }

        if !assetCatalog.hasSuffix(".xcassets") {
            assetCatalog.append(".xcassets")
        }

        let assetCatalogPath = "\(path)/\(assetCatalog)"
        let assetCatalogURL = URL(fileURLWithPath: assetCatalogPath)

        // Write base Contents.json
        try FileManager.default.createDirectory(atPath: assetCatalogPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)

        let baseData = """
        {
          "info" : {
            "author" : "prism",
            "version" : 1
          }
        }
        """.data(using: .utf8)
        try baseData?.write(to: assetCatalogURL.appendingPathComponent("Contents.json") )

        // Write individual colors
        for color in assets.colors {
            let colorFolder = assetCatalogURL.appendingPathComponent("\(color.name).colorset")
            let colorFileURL = colorFolder.appendingPathComponent("Contents.json")
            let colorContent = color.assetCatalogFileContent()

            try FileManager.default.createDirectory(at: colorFolder,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            try (colorContent.data(using: .utf8) ?? Data()).write(to: colorFileURL)
        }
    }
}

// MARK: - Helpers
private extension RawColorRepresentable {
    /// Return the color contents of an Asset Catalog Color File
    func assetCatalogFileContent() -> String {
        """
        {
          "colors" : [
            {
              "color" : {
                "color-space" : "srgb",
                "components" : {
                  "red" : "\(r)",
                  "green" : "\(g)",
                  "blue" : "\(b)",
                  "alpha" : "\(a)"
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
}


extension AssetCatalogGenerator {
    enum Error: Swift.Error, CustomStringConvertible {
        case templateFolderMissing
        case noTemplateFiles
        
        var description: String {
            return ""
        }
    }
}
