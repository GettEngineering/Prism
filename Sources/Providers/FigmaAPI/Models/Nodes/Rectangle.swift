//
//  Rectangle.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    @dynamicMemberLookup
    struct Rectangle: VectorNodeType, Decodable {
        public let vector: Vector
        public let cornerRadius: Float
        public let rectangleCornerRadii: [Float]

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.cornerRadius = try container.decodeIfPresent(.cornerRadius) ?? 0
            self.rectangleCornerRadii = try container.decodeIfPresent(.rectangleCornerRadii) ?? Array(repeating: cornerRadius, count: 4)
        }

        enum CodingKeys: String, CodingKey {
            case cornerRadius, rectangleCornerRadii
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }
    }
}
