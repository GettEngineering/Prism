//
//  File.swift
//  
//
//  Created by Shai Mishali on 06/10/2021.
//

import Foundation
import PrismProvider
public extension Figma {
    static func generate(with configuration: PrismProvider.Configuration<Self>) throws {
        guard let accessToken = ProcessInfo.processInfo.environment["FIGMA_TOKEN"] else {
            throw Error.missingToken
        }

        let figma = Figma(api: .init(accessToken: accessToken))
        let sema = DispatchSemaphore(value: 0)

        try figma.getAssets(for: .file(key: configuration.fileKey)) { result in
            defer { sema.signal() }
            let assets = try result.get()
            try Self.parseTemplates(with: assets, configuration: configuration)
        }

        sema.wait()
    }
}

extension Figma {
    enum Error: Swift.Error, CustomStringConvertible {
        case missingToken

        var description: String {
            switch self {
            case .missingToken:
                return "Missing FIGMA_TOKEN environment variable"
            }
        }
    }
}
