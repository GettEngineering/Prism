//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// Represents an Asset that can be identified with a name.
public protocol AssetIdentifiable {
    var name: String { get }
}

public extension AssetIdentifiable {
    /// A synthesized identity for iOS and Android styles based
    /// on the provided Asset name.
    var identity: Prism.Project.AssetIdentity {
        return .init(name: name)
    }
}

public extension Prism.Project {
    /// An Asset Identity containing different identity styles/flavors.
    struct AssetIdentity {
        private var snakecased: String {
            return words
                .map { $0.lowercased() }
                .joined(separator: "_")
        }

        private var camelcased: String {
            return (words.first?.lowercased() ?? "") +
                    words.dropFirst()
                         .map { $0.capitalized }
                        .joined()
        }

        private let words: [String]

        public let name: String

        init(name: String) {
            self.name = name

            // Seperate name to words
            var words = [String]()
            var currentWord = ""
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: "\\", with: "")
                                .replacingOccurrences(of: "/", with: "")
                                .replacingOccurrences(of: "-", with: " ")
                                .replacingOccurrences(of: "_", with: " ")

            for (idx, char) in cleanName.enumerated() {
                guard idx > 0 else {
                    currentWord.append(char)
                    continue
                }

                let wordCharacterSet = CharacterSet.uppercaseLetters
                                                   .subtracting(CharacterSet.decimalDigits)
                                                   .union(CharacterSet.whitespaces)

                if char.unicodeScalars.allSatisfy(wordCharacterSet.contains) {
                    words.append(currentWord.replacingOccurrences(of: " ", with: ""))
                    currentWord = ""
                    currentWord.append(char)
                } else {
                    currentWord.append(char)
                }
            }

            words.append(currentWord.replacingOccurrences(of: " ", with: ""))
            self.words = words.compactMap { $0.isEmpty ? nil : $0 }
        }
    }
}

extension Prism.Project.AssetIdentity: CustomStringConvertible {
    public var description: String {
        return "AssetIdentity(name: \(name), \(Style.allCases.map { "\($0.rawValue): \($0.identifier(for: self))" }.joined(separator: ", ")))"
    }
}

public extension Prism.Project.AssetIdentity {
    /// An Identity Style
    enum Style: String, CaseIterable {
        /// Camel-cased identifier. "A color 3" => "aColor3"
        case camelcase

        /// Snake-cased identifier. "A color 3" => "a_color_3"
        case snakecase

        public func identifier(for identity: Prism.Project.AssetIdentity) -> String {
            switch self {
            case .snakecase:
                return identity.snakecased
            case .camelcase:
                return identity.camelcased
            }
        }
    }
}
