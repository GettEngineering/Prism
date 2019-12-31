//
//  CommandError.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

enum CommandError: Swift.Error, CustomStringConvertible {
    case invalidCommand
    case missingProjectID
    case missingToken
    case failedDataConversion
    case templateFolderMissing
    case outputFolderMissing
    case noTemplateFiles
    case missingConfigurationFile(path: String)
    case invalidConfiguration(path: String)

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingProjectID:
            return "Missing Zeplin Project ID. Please use the -i flag or provide one in your config.yml"
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        case .templateFolderMissing:
            return "Invalid or missing templates folder. Please provide a valid one via the -t flag or in your config.yml."
        case .outputFolderMissing:
            return "Invalid or missing output folder. Please provide a valid one via the -o flag or in your config.yml."
        case .noTemplateFiles:
            return "Can't find template files (*.prism) in provided folder"
        case .missingConfigurationFile(let path):
            return "Provided configuration path '\(path)' cannot be found"
        case .invalidConfiguration(let path):
            return "Configuration '\(path)' was used, but doesn't seem to be a valid YAML file"
        }
    }
}
