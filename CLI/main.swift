//
//  main.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//

import PrismCore
import Foundation
import Commander

public final class PrismCLI {
    public func run(with arguments: [String] = CommandLine.arguments) throws {
        let commander = BuiltIn.Commander.self

        commander.commands = [
            GenerateCommand.self
        ]

        do {
            try commander.init().dispatch(with: arguments)
        } catch let err {
            let message: String = {
                switch err {
                case OptionsDecoder.Error.decodingError(.keyNotFound(let key, _)):
                    return "Missing option: --\(key.stringValue)"
                default:
                    return "Unknown error: \(err)"
                }
            }()

            print("\(message)")
            try commander.init().dispatch(with: ["prism", "help"])
        }
    }
}

let cli = PrismCLI()
try cli.run()
