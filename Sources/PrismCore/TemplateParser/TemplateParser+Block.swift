//
//  TemplateParser+Block.swift
//  Prism
//
//  Created by Shai Mishali on 07/02/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

// MARK: - Model
extension TemplateParser {
    /// A Template Block represents a nested condition or loop
    /// and the information needed by the parser to process these
    /// various blocks
    ///
    /// For example:
    ///
    ///     {{% FOR color %}}
    ///     content
    ///     {{% END color %}}
    ///
    /// Or:
    ///
    ///     {{% IF someToken %}}
    ///     do something with the {{%someToken%}} value
    ///     {{% ENDIF% }}
    struct Block {
        /// Body of the block, an array of the lines/content
        /// the opening and closing tags of the block
        let body: [String]
        
        /// The content prior to the body and block
        /// - Note: Used when the block is inlined
        let preBody: String?
        
        /// The content after the body and block
        /// - Note: Used when the block is inlined
        let postBody: String?
        
        /// The identifier following the block name
        /// e.g. if writing {{% FOR color %}}, the identifierr
        /// will be "color"
        let identifier: String
        
        /// The index of the last line of the block
        /// which is used by the parser to move on to the next
        /// piece of content after the block is processed
        let endLine: Int

        /// Whether or nor the block is inverted. This is specifically used
        /// in an IF codition, so you could do `IF !condition`
        let isInverted: Bool
    }
}

// MARK: - Loop Position
extension TemplateParser.Block {
    /// Position of element inside containing loop
    enum LoopPosition {
        /// First element in the loop
        case first

        /// Regular element in the middle of the loop
        case middle

        /// Last element in the loop
        case last

        /// Single element in the loop
        case single
    }
}

// MARK: - Detection
extension TemplateParser {
    /// Attempt to detect a block identified by a keyword
    /// and optional ending keyword in an array of lines,
    /// starting from the provided current line index.
    ///
    /// - parameter keyword: A keyword for the block, for example: `FOR`
    /// - parameter end: An optional ending for the block. If omitted, `END {identifier}` is used by default
    /// - parameter lines: Array of lines being processed
    /// - parameter currentLineIdx: The index of the current line to check against
    ///
    /// - returns: A processed `Block` information, or `nil` if a block can't be
    ///            detected within the provided line
    func detectBlock(keyword: String,
                     end: String? = nil,
                     lines: [String],
                     currentLineIdx: Int) throws -> Block? {
        let currentLine = lines[currentLineIdx]
        let lineLength = currentLine.count

        // Find occurences of block in the template
        // Find matching END
        
        let blockRegex = try NSRegularExpression(pattern: #"\{\{\% "# + keyword + #" (.*?) %\}\}((.*?)\{\{\% "# + (end ?? "END \\2") + #" \%\}\})?"#)

        // Detected the provided loop
        guard let blockMatch = blockRegex.firstMatch(in: currentLine,
                                                     options: .init(),
                                                     range: NSRange(location: 0, length: lineLength)) else {
            return nil
        }
        
        let nsLine = currentLine as NSString
        let fullMatchRange = blockMatch.range(at: 0)
        let fullMatch = nsLine.substring(with: fullMatchRange)
        let pieces = currentLine.components(separatedBy: fullMatch)

        guard pieces.count == 2 else { return nil }

        let preBody = pieces[0]
        let postBody = pieces[1]
        let indent = preBody.prefix(while: { $0 == " " })
        
        let rawIdentifier = nsLine.substring(with: blockMatch.range(at: 1))

        // if the first character of the token is `!`, we consider this to be an
        // inverted block. This is used to flip the condition of an `IF` block, for example
        let isInverted = rawIdentifier.first == "!"
        let cleanIdentifier = isInverted ? String(rawIdentifier.dropFirst()) : rawIdentifier

        // We want to give the consumer the option to check `{{% IF textStyle.color %}}`,
        // but that isn't an actual valid token, so we replace it with an identity token
        // as an alias for the specific conditional case
        let identifier = cleanIdentifier.lowercased() == "textstyle.color" ? "textStyle.color.identity" : cleanIdentifier
        
        // If we have the fourth optional match, it means there's
        // an in-line closing of the block instead of in a new-line
        if blockMatch.range(at: 2).location != NSNotFound {
            let body = nsLine.substring(with: blockMatch.range(at: 3))
            return Block(body: [body],
                         preBody: preBody,
                         postBody: postBody,
                         identifier: identifier,
                         endLine: currentLineIdx,
                         isInverted: isInverted)
        }
        
        // Otherwise, we look for the next line that closes
        // the opening loop, or throw an error otherwise
        let endTerm = end ?? "END \(identifier)"
        
        guard let blockEnd = lines[currentLineIdx..<lines.count]
                                .firstIndex(where: { $0 == "\(indent){{% \(endTerm) %}}" }) else {
            throw Error.openBlock(keyword: keyword, identifier: identifier)
        }
        
        let body = Array(lines[currentLineIdx + 1...blockEnd - 1])
        return Block(body: body,
                     preBody: nil,
                     postBody: nil,
                     identifier: identifier,
                     endLine: blockEnd,
                     isInverted: isInverted)
    }
}
