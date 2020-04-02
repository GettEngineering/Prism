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
import ZeplinAPI
import Darwin

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
        let api = ZeplinAPI(jwtToken: jwtToken)
        let fileManager = FileManager.default
        
        // Information needed for config.yml creation
        let project: Project
        var outputPath = ""

        guard !fileManager.fileExists(atPath: configPath) ||
            UserInput(message: "It seems you already have a configuration file. Running through this wizard will overwrite it. Are you sure?").request() else {
            Darwin.exit(1)
        }
        
        // Start onboarding
        print("""

        🖌  Welcome to Prism 🌈!

        This quick wizard will get you started with configuring your project.
        """)
        
        let isReady: Bool = UserInput(message: "Ready to get started?").request()
        guard isReady else { return }

        // Let user select a project
        print("⏳ Getting your projects ...")
        
        let group = DispatchGroup()
        group.enter()
        var projects = [Project]()
        
        api.getProjects { result in
            do {
                defer { group.leave() }
                projects = try result.get().filter { $0.status == .active }
            } catch let err {
                print("Failed fetching projects: \(err)")
                Darwin.exit(1)
            }
        }
        
        group.wait()
        
        guard !projects.isEmpty else {
            print("❌ No projects found for your user!")
            Darwin.exit(1)
        }
        
        print("🔎 Found \(projects.count) projects:")
        
        for (idx, project) in projects.enumerated() {
            print("  \(idx+1)) \(project.platform.emoji) \(project.name) (\(project.numberOfColors) colors, \(project.numberOfTextStyles) text styles)")
        }
        
        let projectNumber = UserInput(message: "Pick a project").request(range: 1...projects.count)
        project = projects[projectNumber - 1]
        
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
                print("❌ Failed creating .prism folder: \(error)")
                Darwin.exit(1)
            }
        }

        // Assemble config.yml file
        print("💾 Saving your configuration...")
        var config = [String]()
        
        config.append("project_id: \"\(project.id)\"")
        config.append("templates_path: \".prism\"")
        config.append("output_path: \"\(outputPath)\"")
        
        // Save it!
        do {
            try config.joined(separator: "\n")
                      .write(toFile: configPath,
                             atomically: true,
                             encoding: .utf8)
        } catch {
            print("❌ Failed creating config.yml file: \(error)")
            Darwin.exit(1)
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

// MARK: - User Input
struct UserInput {
    let message: String
    
    private func getInput() -> String {
        guard let value = readLine() else {
            fatalError("Failed fetching user input")
        }
        
        return value
    }
    
    func request() -> Bool {
        print("\(message) [Y/n]: ", terminator: "")
        let input = getInput()
        
        switch input {
        case "Y":
            return true
        case "n":
            return false
        default:
            print("❌ '\(input)' is not a valid value. Valid options are `Y` for yes or `n` for no.")
            return request()
        }
    }
    
    func request() -> String {
        print("\(message): ", terminator: "")
        let input = getInput()
        return input
    }
    
    func request(range: ClosedRange<Int>? = nil) -> Int {
        print("\(message): ", terminator: "")
        let input = getInput()
        
        guard let value = Int(input) else {
            print("❌ '\(input)' is not a valid number. Please try again.")
            return request()
        }
        
        if let range = range,
           !range.contains(value) {
            print("❌ '\(value)' should be between \(range.lowerBound) and \(range.upperBound). Please try again.")
            return request()
        }
        
        return value
    }
}

// MARK: - File Manager Helpers
extension FileManager {
    func folderExists(at path: String) -> Bool {
        var isDir: ObjCBool = false
        return fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }
}
