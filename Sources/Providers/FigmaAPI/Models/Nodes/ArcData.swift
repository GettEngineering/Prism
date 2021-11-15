//
//  ArcData.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    struct ArcData: Decodable {
        public let startingAngle: Float
        public let endingAngle: Float
        public let innerRadius: Float
    }
}
