//
//  Canvas.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public extension Node {
    struct Canvas: Decodable {
        public let backgroundColor: Color
        public let flowStartingPoints: [FlowStartingPoint]
    }
}

public extension Node.Canvas {
    struct FlowStartingPoint: Decodable {
        let nodeId: String
        let name: String
    }
}
