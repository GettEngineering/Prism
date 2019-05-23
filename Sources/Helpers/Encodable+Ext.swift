//
//  Encodable+Ext.swift
//  PrismCore
//
//  Created by Shai Mishali on 22/05/2019.
//

import Foundation

extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
