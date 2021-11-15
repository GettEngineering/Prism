//
//  Spacing.swift
//  Prism
//
//  Created by Shai Mishali on 03/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

/// A unit of spacing between components or
/// other visual elements
public struct Spacing: AssetIdentifiable, Codable, Equatable {
    /// Spacing ID
    public let id: String

    /// Spacing name
    public let name: String

    /// Spacing value
    public let value: Float

    /// The spacing's overlay color
    public let color: Color

    public init(
        id: String,
        name: String,
        value: Float,
        color: Color
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.color = color
    }
}
