//
//  Metrics.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct Box: Decodable {
    public let x: Float
    public let y: Float
    public let width: Float
    public let height: Float

    public var point: Point { .init(x: x, y: y) }
    public var size: Size { .init(width: width, height: height) }

    static public var zero: Self { .init(x: 0, y: 0, width: 0, height: 0) }
}

public struct Size: Decodable {
    public let width: Float
    public let height: Float

    public static var zero: Self { .init(width: 0, height: 0) }
}

public struct Point: Decodable {
    public let x: Float
    public let y: Float

    public static var zero: Self { .init(x: 0, y: 0) }
}
