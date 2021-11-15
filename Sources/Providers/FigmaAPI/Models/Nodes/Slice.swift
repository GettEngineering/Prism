//
//  Slice.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    struct Slice: Decodable {
        public let absoluteBoundingBox: Box
        public let size: Size

        enum CodingKeys: String, CodingKey {
            case absoluteBoundingBox, size
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.absoluteBoundingBox = (try? container.decode(.absoluteBoundingBox)) ?? .zero
            self.size = try container.decodeIfPresent(.size) ?? .zero
        }
    }
}
