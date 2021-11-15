//
//  Paint.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct Paint: Decodable {
    public let type: Kind
    public let isVisible: Bool
    public let opacity: Float
    public let color: Color?
    public let blendingMode: BlendingMode
    public let gradientHandlePositions: [Point]
    public let gradientStops: [ColorStop]
    public let scaleMode: ScaleMode

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(.type)
        self.isVisible = try container.decodeIfPresent(.visible) ?? true
        self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0

        // Figma has a known bug where the color opacity is incorrect. This works around
        // this by using the fill opacity instead, which is equivalent.
        if let rawColor = try container.decodeIfPresent(Color.self, forKey: .color) {
            self.color = Color(r: rawColor.r, g: rawColor.g, b: rawColor.b, a: opacity)
        } else {
            self.color = nil
        }

        self.blendingMode = try container.decode(.blendMode)
        self.gradientHandlePositions = try container.decodeIfPresent(.gradientHandlePositions) ?? []
        self.gradientStops = try container.decodeIfPresent(.gradientStops) ?? []
        self.scaleMode = try container.decodeIfPresent(.scaleMode) ?? .fill
    }

    enum CodingKeys: String, CodingKey {
        case type,
             visible,
             opacity,
             color,
             blendMode,
             gradientHandlePositions,
             gradientStops,
             scaleMode
    }

    public enum Kind: String, Decodable {
        case solid = "SOLID"
        case linearGradient = "GRADIENT_LINEAR"
        case radialGradient = "GRADIENT_RADIAL"
        case angularGradient = "GRADIENT_ANGULAR"
        case diamongGradient = "GRADIENT_DIAMOND"
        case image = "IMAGE"
        case emoji = "EMOJI"
    }
}

public enum BlendingMode: String, Decodable {
    case passThrough = "PASS_THROUGH"
    case normal = "NORMAL"

    // Darken
    case darken = "DARKEN"
    case multiply = "MULTIPLY"
    case linearBurn = "LINEAR_BURN"
    case colorBurn = "COLOR_BURN"

    // Lighten
    case lighten = "LIGHTEN"
    case screen = "SCREEN"
    case linearDodge = "LINEAR_DODGE"
    case colorDodge = "COLOR_DODGE"

    // Contrast
    case overlay = "OVERLAY"
    case softLight = "SOFT_LIGHT"
    case hardLight = "HARD_LIGHT"

    // Inversion
    case difference = "DIFFERENCE"
    case exclusion = "EXCLUSION"

    // Component
    case hue = "HUE"
    case saturation = "SATURATION"
    case color = "COLOR"
    case luminosity = "LUMINOSITY"
}

public enum ScaleMode: String, Decodable {
    case fill = "FILL"
    case fit = "FIT"
    case tile = "TILE"
    case stretch = "STRETCH"
}
