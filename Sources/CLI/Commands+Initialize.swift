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

// MARK: - Initialize command
struct Initialize: ParsableCommand {
    static var configuration = CommandConfiguration(
      commandName: "init",
      abstract: "Bootstrap Prism for your project"
    )

    func run() throws {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        let configPath = ".prism/config.yml"
        let fileManager = FileManager.default
        let api = ZeplinAPI(jwtToken: jwtToken)
        
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

        let assetType: AssetType = UserInput(message: "🎨 Use a project or style guide?").request()
        
        let group = DispatchGroup()
        var config = [String]()

        switch assetType {
        case .project:
            pickProject(api: api, config: &config, dispatchGroup: group)
        case .styleguide:
            pickStyleguide(api: api, config: &config, dispatchGroup: group)
        }
        
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

        // Assemble config.yml file
        print("💾 Saving your configuration...")
        config.append("templates_path: \".prism\"")
        config.append("output_path: \"\(outputPath)\"")
        
        // Save it!
        do {
            try config.joined(separator: "\n")
                      .write(toFile: configPath,
                             atomically: true,
                             encoding: .utf8)
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

    /// Let the user pick a single Zeplin project for Prism
    /// to generate your design code from
    ///
    /// - parameter api: An instance of a Zeplin API
    /// - parameter config: An `inout` array representing prism options
    /// - parameter disaptchGroup: A `DispatchGroup` for the API requests
    private func pickProject(api: ZeplinAPI,
                             config: inout [String],
                             dispatchGroup: DispatchGroup) {
        // Let user select a project
        print("⏳ Getting your projects ...")

        dispatchGroup.enter()
        var projects = [Project]()

        api.getProjects { result in
            do {
                defer { dispatchGroup.leave() }
                projects = try result.get().filter { $0.status == .active }
            } catch let err {
                terminate(with: "Failed fetching projects: \(err)")
            }
        }

        dispatchGroup.wait()

        guard !projects.isEmpty else {
            terminate(with: "❌ No projects found for your user!")
        }

        print("🔎 Found \(projects.count) projects:")

        for (idx, project) in projects.enumerated() {
            print("  \(idx+1)) \(project.platform.emoji) \(project.name)")
        }

        let projectNumber = UserInput(message: "Pick a project").request(range: 1...projects.count)
        let project = projects[projectNumber - 1]

        config.append("project_id: \"\(project.id)\"")
    }

    /// Let the user pick a single Zeplin style guide for Prism
    /// to generate your design code from
    ///
    /// - parameter api: An instance of a Zeplin API
    /// - parameter config: An `inout` array representing prism options
    /// - parameter disaptchGroup: A `DispatchGroup` for the API requests
    private func pickStyleguide(api: ZeplinAPI,
                                config: inout [String],
                                dispatchGroup: DispatchGroup) {
        // Let user select a project
        print("⏳ Getting your styleguides ...")

        dispatchGroup.enter()
        var styleguides = [Styleguide]()

        api.getStyleguides { result in
            do {
                defer { dispatchGroup.leave() }
                styleguides = try result.get().filter { $0.status == .active }
            } catch let err {
                terminate(with: "Failed fetching styleguides: \(err)")
            }
        }

        dispatchGroup.wait()

        guard !styleguides.isEmpty else {
            terminate(with: "❌ No styleguides found for your user!")
        }

        print("🔎 Found \(styleguides.count) styleguides:")

        for (idx, project) in styleguides.enumerated() {
            print("  \(idx+1)) \(project.platform.emoji) \(project.name)")
        }

        let projectNumber = UserInput(message: "Pick a stylegude").request(range: 1...styleguides.count)
        let styleguide = styleguides[projectNumber - 1]

        config.append("styleguide_id: \"\(styleguide.id)\"")
    }
}

private enum AssetType: InputOption, CaseIterable {
    case project
    case styleguide

    var aliases: [String] {
        switch self {
        case .project:
            return ["project", "p"]
        case .styleguide:
            return ["styleguide", "s"]
        }
    }
}
