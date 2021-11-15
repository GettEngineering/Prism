//
//  BooleanOperation.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    @dynamicMemberLookup
    struct BooleanOperation: VectorNodeType, Decodable {
        public let vector: Vector
        public let operation: Operation

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.operation = try container.decode(.booleanOperation)
        }

        enum CodingKeys: String, CodingKey {
            case booleanOperation
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }

        public enum Operation: String, Decodable {
            case union = "UNION"
            case intersect = "INTERSECT"
            case subtract = "SUBTRACT"
            case exclude = "EXCLUDE"
        }
    }
}
