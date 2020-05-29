//
//  Configuration.swift
//  Prism
//
//  Created by Shai Mishali on 31/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Yams

public struct Configuration {
    /// Zeplin Project ID
    public let projectId: String?

    /// Zeplin Styleguide ID
    public let styleguideId: String?
    
    /// Path to look for *.prism templates in
    public let templatesPath: String?
    
    /// Path to output the result of template processing to
    public let outputPath: String?
    
    /// A list of reserved color identities that cannot be used.
    public let reservedColors: [String]

    /// A list of reserved text style identities that cannot be used.
    public let reservedTextStyles: [String]

    /// Asset Catalog Configuration
    public let assetCatalog: AssetCatalog
}

public extension Configuration {
    /// Asset Catalog Coniguration
    struct AssetCatalog: Codable {
        /// Name of generated Asset Catalog
        public let name: String?

        /// Path to output asset catalog to
        public let outputPath: String?

        enum CodingKeys: String, CodingKey {
            case name
            case outputPath = "output_path"
        }
    }
}

extension Configuration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.projectId = try? container.decode(String.self, forKey: .projectId)
        self.styleguideId = try? container.decode(String.self, forKey: .styleguideId)
        self.templatesPath = try? container.decode(String.self, forKey: .templatesPath)
        self.outputPath = try? container.decode(String.self, forKey: .outputPath)
        self.reservedColors = (try? container.decode([String].self, forKey: .reservedColors)) ?? []
        self.reservedTextStyles = (try? container.decode([String].self, forKey: .reservedTextStyles)) ?? []
        self.assetCatalog = try container.decode(AssetCatalog.self, forKey: .assetCatalog)
    }

    public static let prismFolder = ".prism"

    public init(path configFile: String?) throws {
        let defaultConfigPath = "\(Configuration.prismFolder)/config.yml"
        let configPath = configFile ?? defaultConfigPath

        let config: Configuration
        guard let configData = FileManager.default.contents(atPath: configPath),
              let configString = String(data: configData, encoding: .utf8) else {
            throw ConfigurationError.missingConfigurationFile(path: configPath)
        }

        let decoder = YAMLDecoder()

        do {
            config = try decoder.decode(Configuration.self, from: configString)
        } catch {
            throw ConfigurationError.invalidConfiguration(path: configPath)
        }

        self.projectId = config.projectId
        self.templatesPath = config.templatesPath
        self.outputPath = config.outputPath
        self.reservedColors = config.reservedColors
        self.reservedTextStyles = config.reservedTextStyles
        self.assetCatalog = config.assetCatalog
    }
    
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case styleguideId = "styleguide_id"
        case templatesPath = "templates_path"
        case outputPath = "output_path"
        case reservedColors = "reserved_colors"
        case reservedTextStyles = "reserved_textstyles"
        case assetCatalog = "asset_catalog"
    }
}

enum ConfigurationError: Swift.Error, CustomStringConvertible {
    case missingConfigurationFile(path: String)
    case invalidConfiguration(path: String)

    var description: String {
        switch self {
        case .missingConfigurationFile(let path):
            return "Provided configuration path '\(path)' cannot be found"
        case .invalidConfiguration(let path):
            return "Configuration '\(path)' was used, but doesn't seem to be a valid YAML file"
        }
    }
}
