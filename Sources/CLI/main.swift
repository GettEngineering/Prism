//
//  main.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import PrismCore
import Foundation
import Commander

public final class PrismCLI {
    public func run(with arguments: [String] = CommandLine.arguments) throws {
        let commander = BuiltIn.Commander.self

        commander.commands = [
            GenerateCommand.self,
            InitializeCommand.self
        ]

        do {
            try commander.init().dispatch(with: arguments)
        } catch let err {
            var showUsage = false
            let message: String = {
                switch err {
                case is OptionsDecoder.Error,
                     is Commander.Error:
                    showUsage = true
                    let args = String(arguments.dropFirst().joined(separator: " ")).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if args.isEmpty {
                        return "Please provide a command to prism"
                    } else {
                        return "The command 'prism \(args)' is invalid"
                    }
                default:
                    return "\(err)"
                }
            }()

            print("❌ Error: \(message)")
            if showUsage {
                try commander.init().dispatch(with: ["prism", "help"])
            }
        }
    }
}

let cli = PrismCLI()
try cli.run()
