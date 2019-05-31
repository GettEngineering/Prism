//
//  Configuration.swift
//  PrismCore
//
//  Created by Shai Mishali on 31/05/2019.
//

import Foundation

public struct Configuration {
    /// A list of reserved color identities that cannot be used.
    public let reservedColors: [String]

    /// A list of reserved text style identities that cannot be used.
    public let reservedTextStyles: [String]
}

extension Configuration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.reservedColors = (try? container.decode([String].self, forKey: .reservedColors)) ?? []
        self.reservedTextStyles = (try? container.decode([String].self, forKey: .reservedTextStyles)) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case reservedColors = "reserved_colors"
        case reservedTextStyles = "reserved_textstyles"
    }
}
