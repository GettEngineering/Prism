//
//  main.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import PrismCore
import Foundation
import ArgumentParser
//import FigmaAPI

struct PrismCLI: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "prism",
        abstract: "🎨 A CLI to Generate platform-specific design code from Zeplin Projects",
        subcommands: [Initialize.self, Generate.self]
    )
}

#if canImport(WinSDK)
// Enable unicode for Windowws, if available
import WinSDK
import Yams
SetConsoleOutputCP(65001)
#endif

PrismCLI.main()
