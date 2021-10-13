//
//  File.swift
//  
//
//  Created by Shai Mishali on 12/10/2021.
//

import Foundation
import ProviderCore
import FigmaSwift

extension Figma {
    public static func initialize() throws -> Configuration {
        return .init(files: [])
    }
}
