//
//  Commands+Initialize.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ArgumentParser
import PrismCore
import Yams
import ZeplinSwift
import ProviderCore

// MARK: - Initialize command
struct Initialize: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "init",
      abstract: "Bootstrap Prism for your project"
    )

    func run() throws {
        let configPath = ".prism/config.yml"
        let fileManager = FileManager.default

        // Information needed for config.yml creation
        var outputPath = ""

        guard !fileManager.fileExists(atPath: configPath) ||
            UserInput(message: "It seems you already have a configuration file. Running through this wizard will overwrite it. Are you sure?").request() else {
            terminate(with: nil)
        }
        
        // Start onboarding
        print("""

        🖌  Welcome to Prism 🌈!

        This quick wizard will get you started with configuring your project.
        """)

        guard UserInput(message: "Ready to get started?").request() else { return }

        // Pick a provider
        let provider = UserInput(message: "Which provider are you using?").request(options: AssetProvider.allCases)

        // Get output folder for Prism template output
        if UserInput(message: "📂 Use current folder as output folder for Prism?").request() {
           outputPath = "./"
        } else {
            repeat {
                let folderPath: String = UserInput(message: "📂 Type in an output folder path for Prism").request()

                if !fileManager.folderExists(at: folderPath),
                   UserInput(message: "Folder at path \(folderPath) doesn't seem to exist. Create it?").request() {
                    do {
                        try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
                        outputPath = folderPath
                    } catch {
                        print("❌ Failed creating folder \(folderPath): \(error)")
                        continue
                    }
                }

                outputPath = folderPath
            } while outputPath.isEmpty
        }

        // Make sure `.prism` folder exists
        // Otherwise, create it
        if !fileManager.folderExists(at: ".prism") {
            print("📂 .prism folder doesn't exist, creating...")

            do {
                try fileManager.createDirectory(atPath: ".prism", withIntermediateDirectories: false, attributes: nil)
            } catch {
                terminate(with: "❌ Failed creating .prism folder: \(error)")
            }
        }

        let encoder = JSONEncoder()
        let yaml: String

        do {
            switch provider {
            case .zeplin:
                let config = Configuration<Zeplin>(
                    providerConfiguration: try Zeplin.initialize(),
                    templatesPath: ".prism",
                    outputPath: outputPath,
                    reservedColors: [],
                    reservedTextStyles: []
                )

                yaml = String(data: try encoder.encode(config), encoding: .utf8)!
            case .figma:
                let config = Configuration<Figma>(
                    providerConfiguration: try Figma.initialize(),
                    templatesPath: ".prism",
                    outputPath: outputPath,
                    reservedColors: [],
                    reservedTextStyles: []
                )

                yaml = String(data: try encoder.encode(config), encoding: .utf8)!
            }

            print("💾 Saving your configuration...")
            try yaml.write(toFile: configPath, atomically: true, encoding: .utf8)
        } catch {
            terminate(with: "❌ Failed creating config.yml file: \(error)")
        }
        
        print("""

        ✅ All done! Enjoy using Prism! 🥳

        Next steps:
         1️⃣  Add some *.prism templates inside your newly-created .prism folder
         2️⃣  Run `prism generate`
         3️⃣  Your processed files will live inside your output folder: '\(outputPath)'
        """)
    }
}

extension AssetProvider: InputOption {
    public var aliases: [String] {
        return [rawValue]
    }
}
