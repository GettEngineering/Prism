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
import PrismProvider

// MARK: - Generate command
struct Generate: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"
    )

    @Option(name: .shortAndLong, help: "Path to YAML configuration file")
    var configFile: String?
    
    func run() throws {
        let prismFolder = ".prism"
        let configPath = configFile ?? "\(prismFolder)/config.yml"

        if !FileManager.default.fileExists(atPath: configPath) {
            throw CommandError.missingConfigurationFile(path: configPath)
        }

        // Configuration
        guard let configData = FileManager.default.contents(atPath: configPath),
              let rawConfig = String(data: configData, encoding: .utf8) else {
            throw CommandError.missingConfigurationFile(path: configPath)
        }

        let decoder = YAMLDecoder()
        let provider: AssetProvider

        do {
            let providerConfig = try decoder.decode(ConfigurationProvider.self, from: rawConfig)
            provider = providerConfig.kind
        } catch let error as DecodingError {
            throw Error.invalidProvider(rawConfig, underlyingError: error)
        } catch {
            throw error
        }

        do {
            switch provider {
            case .zeplin:
                try Zeplin.attemptGenerating(with: rawConfig)
            case .figma:
                try Figma.attemptGenerating(with: rawConfig)
            }
        }
    }
}

struct ConfigurationProvider: Decodable {
    let kind: AssetProvider

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let providerContainer = try container.nestedContainer(keyedBy: ProviderKeys.self, forKey: .provider)

        self.kind = try providerContainer.decode(AssetProvider.self, forKey: .kind)
    }

    enum CodingKeys: String, CodingKey { case provider }

    enum ProviderKeys: String, CodingKey { case kind }
}

extension AssetProviding {
    static func attemptGenerating(with configuration: String) throws {
        let decoder = YAMLDecoder()

        do {
            let config = try decoder.decode(
                PrismProvider.Configuration<Self>.self,
                from: configuration
            )

            try generate(with: config)
        } catch let error as DecodingError {
            throw Generate.Error.invalidConfiguration(underlyingError: error)
        } catch {
            throw error
        }
    }
}

extension Generate {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidProvider(String, underlyingError: DecodingError)
        case invalidConfiguration(underlyingError: DecodingError)

        var description: String {
            switch self {
            case .invalidProvider:
                return "Please provide a valid value for `provider.kind`. Possible options are: \(AssetProvider.allCases.map(\.rawValue).joined(separator: ", "))."
            case .invalidConfiguration:
                return "Configuration for provider is invalid. Check the documentation and try again."
            }
        }
    }
}
