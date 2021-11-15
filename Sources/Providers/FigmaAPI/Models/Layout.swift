//
//  Layout.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public enum LayoutMode: String, Decodable {
    case none = "NONE"
    case horizontal = "HORIZONTAL"
    case vertical = "VERTICAL"
}

public struct AxisConstraints: Decodable {
    public let vertical: LayoutConstraint
    public let horizontal: LayoutConstraint
}

public enum LayoutConstraint: String, Decodable {
    // Vertical
    case top = "TOP"
    case bottom = "BOTTOM"
    case topBottom = "TOP_BOTTOM"

    // Horizontal
    case left = "LEFT"
    case right = "RIGHT"
    case leftRight = "LEFT_RIGHT"

    // Both
    case center = "CENTER"
    case scale = "SCALE"
}
