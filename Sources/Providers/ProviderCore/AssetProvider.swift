//
//  Provider.swift
//  Prism
//
//  Created by Shai Mishali on 10/2/21.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

/// A possible asset provider for Colors, Text Styles, etc.
public enum AssetProvider: String, CaseIterable, Codable {
    /// Zeplin
    case zeplin

    /// Figma
    case figma
}

/// Represents a service provider that lets you fetch colors,
/// text styles, spacings, and any other assets
public protocol AssetProviding {
    /// An associated configuration for the provider
    associatedtype Configuration: Decodable

    /// A scope for fetching assets, for example owner for Zeplin, or file_id for Figma
    associatedtype Scope

    /// An API for the provider
    associatedtype API: ProviderAPI

    /// A statically-typed asset provider (i.e. `.figma` or `.zeplin`)
    static var provider: AssetProvider { get }

    /// Iterate over the provided templates and generate output files
    /// from them, and finally storing them in the correct output location
    ///
    /// - parameter configuration: A provider-specific configuration object
    static func generate(with configuration: ProviderCore.Configuration<Self>) throws

    /// Fetch Prism assets from the provider, in the provided `Scope`
    ///
    /// - parameter scope: Scope to fetch assets for
    /// - parameter completion: A completion closure invoked upon success or failure
    func getAssets(
        for scope: Scope,
        completion: @escaping (Result<Assets, API.Error>) throws -> Void
    ) throws

    /// An initializer which accepts a provider-specific API client
    init(api: API)
}

/// Represents a service provider API
public protocol ProviderAPI {
    // An associated error type for this API Provider
    associatedtype Error: Swift.Error

    static var baseURL: URL { get }
}
