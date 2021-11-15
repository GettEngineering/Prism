//
//  Frame.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    struct Frame: Decodable {
        public let locked: Bool
        public let fills: [Paint]
        public let strokes: [Paint]
        public let strokeWeight: Float
        public let strokeAlign: StrokeAlign
        public let cornerRadius: Float
        public let rectangleCornerRadiiNumber: [Float]
        public let blendingMode: BlendingMode
        public let shouldPreserveRatio: Bool
        public let constraints: AxisConstraints
        public let opacity: Float
        public let absoluteBoundingBox: Box
        public let size: Size
        public let clipsContent: Bool
        public let layoutMode: LayoutMode
        public let paddingLeft: Float
        public let paddingRight: Float
        public let paddingBottom: Float
        public let paddingTop: Float
        public let horizontalPadding: Float
        public let verticalPadding: Float
        public let itemSpacing: Float

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.locked = try container.decodeIfPresent(.locked) ?? false
            self.fills = try container.decodeIfPresent(.fills) ?? []
            self.strokes = try container.decodeIfPresent(.strokes) ?? []
            self.strokeWeight = try container.decode(.strokeWeight)
            self.strokeAlign = try container.decode(.strokeAlign)
            self.cornerRadius = try container.decodeIfPresent(.cornerRadius) ?? 0
            self.rectangleCornerRadiiNumber = try container.decodeIfPresent(.rectangleCornerRadiiNumber) ?? Array(repeating: cornerRadius, count: 4)
            self.blendingMode = try container.decode(.blendMode)
            self.shouldPreserveRatio = try container.decodeIfPresent(.preserveRatio) ?? false
            self.constraints = try container.decode(.constraints)
            self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0
            self.absoluteBoundingBox = (try? container.decode(.absoluteBoundingBox)) ?? .zero
            self.size = try container.decodeIfPresent(.size) ?? .zero
            self.clipsContent = try container.decode(.clipsContent)
            self.layoutMode = try container.decodeIfPresent(.layoutMode) ?? .none
            self.paddingLeft = try container.decodeIfPresent(.paddingLeft) ?? 0
            self.paddingRight = try container.decodeIfPresent(.paddingRight) ?? 0
            self.paddingBottom = try container.decodeIfPresent(.paddingBottom) ?? 0
            self.paddingTop = try container.decodeIfPresent(.paddingTop) ?? 0
            self.horizontalPadding = try container.decodeIfPresent(.horizontalPadding) ?? 0
            self.verticalPadding = try container.decodeIfPresent(.verticalPadding) ?? 0
            self.itemSpacing = try container.decodeIfPresent(.itemSpacing) ?? 0
        }

        enum CodingKeys: String, CodingKey {
            case locked,
                 fills,
                 strokes,
                 strokeWeight,
                 strokeAlign,
                 cornerRadius,
                 rectangleCornerRadiiNumber,
                 blendMode,
                 preserveRatio,
                 constraints,
                 opacity,
                 absoluteBoundingBox,
                 size,
                 clipsContent,
                 layoutMode,
                 paddingLeft,
                 paddingRight,
                 paddingBottom,
                 paddingTop,
                 horizontalPadding,
                 verticalPadding,
                 itemSpacing
        }
    }

    typealias Component = Frame
    typealias ComponentSet = Frame
    typealias Group = Frame
}
