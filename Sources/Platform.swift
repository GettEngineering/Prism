//
//  Platform.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//

import Foundation

public extension Prism.Project {
    enum Platform: String, Decodable {
        case iOS// = "5c4cafab1a14267a73a8d336"
        case android// = "5c51587a50a594420cdf3dca"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            switch value.lowercased() {
            case "ios":
                self = .iOS
            case "android":
                self = .android
            default:
                throw DecodingError.invalidPlatform(value)
            }
        }

        enum DecodingError: Swift.Error {
            case invalidPlatform(String)
        }
    }
}
