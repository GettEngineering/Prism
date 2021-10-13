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
    public init(
        providerConfiguration: Provider.Configuration,
        templatesPath: String?,
        outputPath: String?,
        reservedColors: [String],
        reservedTextStyles: [String]
    ) {
        self.provider = providerConfiguration
        self.templatesPath = templatesPath
        self.outputPath = outputPath
        self.reservedColors = reservedColors
        self.reservedTextStyles = reservedTextStyles
    }

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

        let provider = try providerContainer.decode(ProviderCore.AssetProvider.self, forKey: .kind)

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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(provider, forKey: .provider)

        var providerContainer = container.nestedContainer(keyedBy: ProviderKeys.self, forKey: .provider)
        try providerContainer.encode(Provider.provider.rawValue, forKey: .kind)

        try container.encodeIfPresent(templatesPath, forKey: .templatesPath)
        try container.encodeIfPresent(outputPath, forKey: .outputPath)

        if !reservedColors.isEmpty {
            try container.encode(reservedColors, forKey: .reservedColors)
        }

        if !reservedTextStyles.isEmpty {
            try container.encode(reservedTextStyles, forKey: .reservedTextStyles)
        }
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
