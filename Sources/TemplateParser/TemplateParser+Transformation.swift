//
//  TemplateParser+Transformation.swift
//  Prism
//
//  Created by Shai Mishali on 29/05/2019.
//

import Foundation

extension TemplateParser {
    /// A transformation function applied to a specific token.
    enum Transformation {
        /// Lowercases a token.
        case lowercase

        /// Uppercases a token.
        case uppercase

        /// Replace a provided string with the second one for a token.
        case replace(String, String)

        init?(rawValue: String) {
            let fullRange = NSRange(location: 0, length: rawValue.count)
            let nsValue = rawValue as NSString
            let pattern = #"^(.*?)(\((.*?)\)){0,1}$"#

            do {
                let regex = try NSRegularExpression(pattern: pattern)
                guard let match = regex.matches(in: rawValue, options: [], range: fullRange).first else {
                    return nil
                }

                let action = nsValue.substring(with: match.range(at: 1))
                let params: [String]

                if match.range(at: 3).location == NSNotFound {
                    params = []
                } else {
                    params = nsValue.substring(with: match.range(at: 3))
                                    .components(separatedBy: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                }

                switch (action, params.count) {
                case ("lowercase", 0):
                    self = .lowercase
                case ("uppercase", 0):
                    self = .uppercase
                case ("replace", 2):
                    self = .replace(params[0], params[1])
                default:
                    return nil
                }
            } catch {
                return nil
            }
        }

        /// Apply the transformation to a provided string.
        ///
        /// - parameter to: Input string
        ///
        /// - returns: Transformed string based on transformation function.
        func apply(to string: String) -> String {
            switch self {
            case .lowercase:
                return string.lowercased()
            case .uppercase:
                return string.uppercased()
            case let .replace(of, with):
                return string.replacingOccurrences(of: of, with: with)
            }
        }
    }
}
