//
//  Zeplin+Generate.swift
//  
//
//  Created by Shai Mishali on 02/10/2021.
//

import Foundation
import PrismProvider
import ZeplinSwift

public extension Zeplin {
    static func generate(with configuration: PrismProvider.Configuration<Self>) throws {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw Error.missingToken
        }

        let ownerProject = configuration.projectId.map { AssetOwner.project(id: $0) }
        let ownerStyleguide = configuration.styleguideId.map { AssetOwner.styleguide(id: $0) }

        // Make sure we have either a project or a styleguide
        guard let owner = ownerProject ?? ownerStyleguide else {
            throw Error.missingOwner
        }

        // Exclusive owner check (you can only have either, but not both)
        if ownerProject != nil && ownerStyleguide != nil {
            throw Error.conflictingOwner
        }

        let zeplin = Zeplin(api: .init(jwtToken: jwtToken))
        let sema = DispatchSemaphore(value: 0)

        try zeplin.getAssets(for: owner) { result in
            defer { sema.signal() }
            let assets = try result.get()
            try Self.parseTemplates(with: assets, configuration: configuration)
        }

        sema.wait()
    }
}

extension Zeplin {
    enum Error: Swift.Error, CustomStringConvertible {
        case missingOwner
        case conflictingOwner
        case missingToken

        var description: String {
            switch self {
            case .missingOwner:
                return "You must provide a Project ID or Styleguide ID. Please provide the approprate flags or provide one in your config.yml"
            case .conflictingOwner:
                return "Please provide either a Project ID or a Styleguide ID; not both."
            case .missingToken:
                return "Missing ZEPLIN_TOKEN environment variable"
            }
        }
    }
}
