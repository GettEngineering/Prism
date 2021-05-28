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
    case missingOwner
    case conflictingOwner
    case missingToken
    case failedDataConversion
    case outputFolderMissing
    case outputFolderDoesntExist(path: String)
    case missingConfigurationFile(path: String)
    case invalidConfiguration(path: String)

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingOwner:
            return "You must provide a Project ID or Styleguide ID. Please provide the approprate flags or provide one in your config.yml"
        case .conflictingOwner:
            return "Please provide either a Project ID or a Styleguide ID; not both."
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        case .outputFolderMissing:
            return "Invalid or missing output folder. Please provide a valid one via the -o flag or in your config.yml."
        case .outputFolderDoesntExist(let path):
            return "Provided output path at '\(path)' doesn't exist"
        case .missingConfigurationFile(let path):
            return "Provided configuration path '\(path)' cannot be found"
        case .invalidConfiguration(let path):
            return "Configuration '\(path)' was used, but doesn't seem to be a valid YAML file"
        }
    }
}
