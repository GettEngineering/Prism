//
//  AssetIdentity.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// Represents an Asset that can be identified by a name.
public protocol AssetIdentifiable {
    var name: String { get }
}

public extension AssetIdentifiable {
    /// A synthesized identity for iOS and Android styles based
    /// on the provided Asset name.
    var identity: AssetIdentity {
        .init(name: name)
    }
}

/// An Asset Identity containing different identity styles/flavors.
public struct AssetIdentity {
    /// A snake-cased version of the name
    private var snakecased: String {
        words
            .map { $0.lowercased() }
            .joined(separator: "_")
    }

    private var kebabcased: String {
        words
            .map { $0.lowercased() }
            .joined(separator: "-")
    }

    private var pascalcased: String {
        guard !camelcased.isEmpty else { return "" }
        
        return camelcased[camelcased.startIndex].uppercased() +
               camelcased[camelcased.index(after: camelcased.startIndex)...]
    }

    /// A camelCased version of the name
    private var camelcased: String {
        /// A set of terms that sould have uppercased presentattion
        /// Usually those would be units of size
        let uppercaseTerms = ["xxs", "xs", "x", "m", "l", "xl", "xxl", "xxxl"]

        return (words.first?.lowercased() ?? "") +
                words.dropFirst()
                     .map { uppercaseTerms.contains($0) ? $0.uppercased() : $0.capitalized }
                     .joined()
    }

    private let words: [String]

    /// The asset's raw name, as provided by the Project
    public let name: String

    public init(name: String) {
        self.name = name

        // Seperate name to words
        var words = [String]()
        var currentWord = ""
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            .components(separatedBy: CharacterSet.alphanumerics.inverted)
                            .joined(separator: " ")

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

extension AssetIdentity: CustomStringConvertible {
    public var description: String {
        "AssetIdentity(name: \(name), \(Style.allCases.map { "\($0.rawValue): \($0.identifier(for: self))" }.joined(separator: ", ")))"
    }
}

public extension AssetIdentity {
    /// An Identity Style
    enum Style: String, CaseIterable {
        /// Raw, unprocessed identifier
        case raw

        /// Camel-cased identifier. "A color 3" => "aColor3"
        case camelcase

        /// Snake-cased identifier. "A color 3" => "a_color_3"
        case snakecase

        /// Kebab-cased identifier. "A color 3" => "a-color-3"
        case kebabcase

        /// Pascal-cased identifieir "hey color 3" => "HeyColor3"
        case pascalcase

        public func identifier(for identity: AssetIdentity) -> String {
            switch self {
            case .raw:
                return identity.name
            case .snakecase:
                return identity.snakecased
            case .camelcase:
                return identity.camelcased
            case .kebabcase:
                return identity.kebabcased
            case .pascalcase:
                return identity.pascalcased
            }
        }
    }
}

