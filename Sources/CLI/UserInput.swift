//
//  UserInput.swift
//  Prism
//
//  Created by Shai Mishali on 09/07/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

// MARK: - User Input
struct UserInput {
    let message: String

    private func getInput() -> String {
        guard let value = readLine() else {
            fatalError("Failed fetching user input")
        }

        return value
    }

    func request() -> Bool {
        print("\(message) [Y/n]: ", terminator: "")
        let input = getInput()

        switch input {
        case "Y":
            return true
        case "n":
            return false
        default:
            print("❌ '\(input)' is not a valid value. Valid options are `Y` for yes or `n` for no.")
            return request()
        }
    }

    func request() -> String {
        print("\(message): ", terminator: "")
        let input = getInput()
        return input
    }

    func request(range: ClosedRange<Int>? = nil) -> Int {
        print("\(message): ", terminator: "")
        let input = getInput()

        guard let value = Int(input) else {
            print("❌ '\(input)' is not a valid number. Please try again.")
            return request()
        }

        if let range = range,
           !range.contains(value) {
            print("❌ '\(value)' should be between \(range.lowerBound) and \(range.upperBound). Please try again.")
            return request()
        }

        return value
    }

    func request<Option: InputOption>(options: [Option]) -> Option {
        print("\(message) [\(options.flatMap(\.aliases).joined(separator: "/"))]: ", terminator: "")
        let input = getInput()

        guard let option = options.first(where: { $0.aliases.contains(input.lowercased()) }) else {
            print("❌ '\(input)' is not a valid option. Valid options are: \(options.flatMap(\.aliases).joined(separator: ", "))")
            return request(options: options)
        }

        return option
    }

    func request<Option: InputOption & CaseIterable>() -> Option {
        let options = Option.allCases
        print("\(message) [\(options.flatMap(\.aliases).joined(separator: "/"))]: ", terminator: "")
        let input = getInput()

        guard let option = options.first(where: { $0.aliases.contains(input.lowercased()) }) else {
            print("❌ '\(input)' is not a valid option. Valid options are: \(options.flatMap(\.aliases).joined(separator: ", "))")
            return request()
        }

        return option
    }
}

// MARK: - Generic input options

protocol InputOption {
    var aliases: [String] { get }
}
