//
//  Style.swift
//  Prism
//
//  Created by Shai Mishali on 01/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct Style: Decodable {
    public let key: String
    public let name: String
    public let type: Kind
    public let description: String

    enum CodingKeys: String, CodingKey {
        case key, name, description
        case type = "styleType"
    }
}

public extension Style {
    typealias ID = String

    enum Kind: String, Decodable {
        case fill
        case text
        case effect
        case grid
        case none

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            guard let kind = Self(rawValue: string.lowercased()) else {
                throw DecodingError.typeMismatch(
                    Self.self,
                    .init(
                        codingPath: [],
                        debugDescription: "Failed decoding \(string) as style kind",
                        underlyingError: nil
                    )
                )
            }

            self = kind
        }
    }
}
