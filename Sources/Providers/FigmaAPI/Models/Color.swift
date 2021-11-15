//
//  Color.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct Color: Decodable {
    public let r: Float
    public let g: Float
    public let b: Float
    public let a: Float
}

public struct ColorStop: Decodable {
    let position: Float
    let color: Color
}
