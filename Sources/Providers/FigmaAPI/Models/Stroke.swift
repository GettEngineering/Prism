//
//  Stroke.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public enum StrokeCap: String, Decodable {
    case none = "NONE"
    case round = "ROUND"
    case square = "SQUARE"
    case lineArrow = "LINE_ARROW"
    case triangleArrow = "TRIANGLE_ARROW"
}

public enum StrokeJoin: String, Decodable {
    case miter = "MITER"
    case bevel = "BEVEL"
    case round = "ROUND"
}

public enum StrokeAlign: String, Decodable {
    case inside = "INSIDE"
    case outside = "OUTSIDE"
    case center = "CENTER"
}

