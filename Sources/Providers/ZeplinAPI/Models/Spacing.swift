//
//  Spacing.swift
//  Prism
//
//  Created by Shai Mishali on 10/04/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// A unit of spacing between components or
/// other visual elements
public struct Spacing: Codable, Equatable {
    /// Spacing ID
    public let id: String

    /// Spacing name
    public let name: String

    /// Spacing value
    public let value: Float

    /// The spacing's overlay color
    public let color: RawColor
}
