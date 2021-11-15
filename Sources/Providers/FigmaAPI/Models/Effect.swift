//
//  Effect.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct Effect: Decodable {
    public let type: Kind
    public let isVisible: Bool
    public let radius: Float
    public let color: Color?
    public let blendMode: BlendingMode
    public let offset: Point
    public let spread: Float
    public let showShadowBehindNode: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(.type)
        self.isVisible = try container.decodeIfPresent(.visible) ?? true
        self.radius = try container.decode(.radius)
        self.color = try container.decodeIfPresent(.color)
        self.blendMode = try container.decodeIfPresent(.blendMode) ?? .normal
        self.offset = try container.decodeIfPresent(.offset) ?? .zero
        self.spread = try container.decodeIfPresent(.spread) ?? 0
        self.showShadowBehindNode = try container.decodeIfPresent(.showShadowBehindNode) ?? false
    }

    enum CodingKeys: String, CodingKey {
        case type,
             visible,
             radius,
             color,
             blendMode,
             offset,
             spread,
             showShadowBehindNode
    }

    public enum Kind: String, Decodable {
        case innerShadow = "INNER_SHADOW"
        case dropShadow = "DROP_SHADOW"
        case layerBlur = "LAYER_BLUR"
        case backgroundBlur = "BACKGROUND_BLUR"
    }
}
