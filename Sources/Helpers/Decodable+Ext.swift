//
//  Decodable+Ext.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

extension Decodable {
    static func decode(from data: Data,
                       keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                       dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970) throws -> Self {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        return try decoder.decode(Self.self, from: data)
    }
}
