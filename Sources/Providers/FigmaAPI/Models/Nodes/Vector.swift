//
//  Vector.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    struct Vector: Decodable, VectorNodeType {
        public let isLocked: Bool
        public let blendingMode: BlendingMode
        public let shouldPreserveRatio: Bool
        public let constraints: AxisConstraints
        public let opacity: Float
        public let absoluteBoundingBox: Box
        public let effects: [Effect]
        public let size: Size
        public let isMask: Bool
        public let fills: [Paint]
        public let strokes: [Paint]
        public let strokeWeight: Float
        public let strokeCap: StrokeCap
        public let strokeJoin: StrokeJoin
        public let strokeDashes: [Float]
        public let strokeMiterAngle: Float
        public let strokeAlign: StrokeAlign
        public let styles: [Style.Kind: Style.ID]

        public var vector: Vector { self }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.isLocked = try container.decodeIfPresent(.locked) ?? false
            self.blendingMode = try container.decode(.blendMode)
            self.shouldPreserveRatio = try container.decodeIfPresent(.preserveRatio) ?? false
            self.constraints = try container.decode(.constraints)
            self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0
            self.absoluteBoundingBox = (try? container.decode(.absoluteBoundingBox)) ?? .zero
            self.effects = try container.decodeIfPresent(.effects) ?? []
            self.size = try container.decodeIfPresent(.size) ?? .zero
            self.isMask = try container.decodeIfPresent(.isMask) ?? false
            self.fills = try container.decodeIfPresent(.fills) ?? []
            self.strokes = try container.decodeIfPresent(.strokes) ?? []
            self.strokeWeight = try container.decode(.strokeWeight)
            self.strokeCap = try container.decodeIfPresent(.strokeCap) ?? .none
            self.strokeJoin = try container.decodeIfPresent(.strokeJoin) ?? .miter
            self.strokeDashes = try container.decodeIfPresent(.strokeDashes) ?? []
            self.strokeMiterAngle = try container.decodeIfPresent(.strokeMiterAngle) ?? 28.96
            self.strokeAlign = try container.decode(.strokeAlign)
            let rawStyles = try container.decodeIfPresent([String: String].self, forKey: .styles) ?? [:]
            self.styles = rawStyles.reduce(into: [Style.Kind: Style.ID]()) { output, kv in
                guard let kind = Style.Kind(rawValue: kv.key) else { return }
                output[kind] = kv.value
            }
        }

        enum CodingKeys: String, CodingKey {
            case locked,
                 blendMode,
                 preserveRatio,
                 constraints,
                 opacity,
                 absoluteBoundingBox,
                 effects,
                 size,
                 isMask,
                 fills,
                 strokes,
                 strokeWeight,
                 strokeCap,
                 strokeJoin,
                 strokeDashes,
                 strokeMiterAngle,
                 strokeAlign,
                 styles
        }
    }

    typealias Star = Vector
    typealias Line = Vector
    typealias RegularPolygon = Vector
}

public protocol VectorNodeType {
    var vector: Node.Vector { get }
}
