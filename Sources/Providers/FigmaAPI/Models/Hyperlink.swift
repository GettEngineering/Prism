//
//  Hyperlink.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public enum Hyperlink: Decodable {
    case url(URL)
    case node(String)

    enum CodingKeys: String, CodingKey {
        case url
        case nodeID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let nodeID = try? container.decode(String.self, forKey: .nodeID) {
            self = .node(nodeID)
        }

        self = .url(try container.decode(URL.self, forKey: .url))
    }
}
