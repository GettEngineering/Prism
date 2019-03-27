//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

protocol AssetIdentifiable {
    var name: String { get }
    var identity: Prism.Project.AssetIdentity { get }
}

extension AssetIdentifiable {
    var identity: Prism.Project.AssetIdentity {
        return .init(name: name)
    }
}

extension Prism.Project {
    struct AssetIdentity {
        let iOS: String
        let android: String

        init(name: String) {
            // Seperate name to words
            var words = [String]()
            var currentWord = ""
            let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: #"\"#, with: "")

            for (idx, char) in cleanName.enumerated() {
                guard idx > 0 else {
                    currentWord.append(char)
                    continue
                }

                if char.unicodeScalars.allSatisfy(CharacterSet.uppercaseLetters.contains) {
                    words.append(currentWord)
                    currentWord = ""
                    currentWord.append(char)
                } else {
                    currentWord.append(char)
                }
            }

            words.append(currentWord)

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
