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
    /// An Asset Identity containing iOS and Android flavored identity
    /// styles base on the separate platforms.
    ///
    /// iOS naming is camel-cased for new words.
    /// Android naming is lower cased and separated by underscores.
    ///
    /// * **Input**: An Asset 5
    /// * **iOS**: anAsset5
    /// * **Android**: an_asset_5
    struct AssetIdentity {
        public let iOS: String
        public let android: String

        init(name: String) {
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
            words = words.compactMap { $0.isEmpty ? nil : $0 }

            self.iOS = (words.first?.lowercased() ?? "") + 
                        words.dropFirst()
                             .map { $0.capitalized }
                             .joined()

            self.android = words
                            .map { $0.lowercased() }
                            .joined(separator: "_")
        }
    }
}
