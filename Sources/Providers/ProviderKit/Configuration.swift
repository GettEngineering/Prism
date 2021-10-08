//
//  Configuration.swift
//  Prism
//
//  Created by Shai Mishali on 31/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct Configuration<Provider: AssetProviding> {
    /// Service provider for styles and colors
    public let provider: Provider.Configuration

    /// Path to look for *.prism templates in
    public let templatesPath: String?
    
    /// Path to output the result of template processing to
    public let outputPath: String?
    
    /// A list of reserved color identities that cannot be used.
    public let reservedColors: [String]

    /// A list of reserved text style identities that cannot be used.
    public let reservedTextStyles: [String]

    public subscript<T>(dynamicMember keyPath: KeyPath<Provider.Configuration, T>) -> T {
        provider[keyPath: keyPath]
    }
}

extension Configuration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let providerContainer = try container.nestedContainer(keyedBy: ProviderKeys.self, forKey: .provider)

        let provider = try providerContainer.decode(PrismProvider.AssetProvider.self, forKey: .kind)

        if provider != Provider.provider {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [CodingKeys.provider],
                      debugDescription: "Configured provider '\(provider)' doesn't match provider type '\(Provider.provider)'",
                      underlyingError: nil)
            )
        }

        self.provider = try container.decode(Provider.Configuration.self, forKey: .provider)
        self.templatesPath = try? container.decode(String.self, forKey: .templatesPath)
        self.outputPath = try? container.decode(String.self, forKey: .outputPath)
        self.reservedColors = (try? container.decode([String].self, forKey: .reservedColors)) ?? []
        self.reservedTextStyles = (try? container.decode([String].self, forKey: .reservedTextStyles)) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case provider
        case templatesPath = "templates_path"
        case outputPath = "output_path"
        case reservedColors = "reserved_colors"
        case reservedTextStyles = "reserved_textstyles"
    }

    enum ProviderKeys: String, CodingKey {
        case kind
    }
}
