//
//  Instance.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    @dynamicMemberLookup
    struct Instance: VectorNodeType, Decodable {
        public let vector: Vector
        public let componentId: String?

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.componentId = try container.decodeIfPresent(.componentId)
        }

        public enum CodingKeys: String, CodingKey {
            case componentId
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }
    }
}
