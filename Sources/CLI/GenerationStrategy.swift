//
//  GenerationStrategy.swift
//  Prism
//
//  Created by Shai Mishali on 17/01/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation
import PrismCore

/// Represents a straetgy to generate some output from a given
/// set of assets and configuraiton, for a specific execution
/// of the `Generate` command
protocol GenerationStrategy {
    static func generate(
        to path: String,
        command: Generate,
        from assets: Assets,
        with configuration: Configuration?
    ) throws
}
