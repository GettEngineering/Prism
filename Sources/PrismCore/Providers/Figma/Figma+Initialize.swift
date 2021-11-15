//
//  Figma+Initialize.swift
//  Prism
//
//  Created by Shai Mishali on 12/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation
import ProviderCore
import FigmaSwift

extension Figma {
    public static func initialize() throws -> Configuration {
        print("""

                   =+++++=======
                  +++++++========
                  +++++++=Figma====
                   :+++++=======
                     .+++    .
                   -=====  .====
                  ======= =======     Figma ➡ Prism = 🌈 🎨
                  ======= =======
                   -=====  .====
                     .===
                   .=====
                  =======
                  =======
                   -====

        ┌────────────────────────────────────────────────────────────┐
        │ NOTE: Figma doesn't have a way to list all available       │
        │ files. Instead, simply go to Figma on the web, and paste   │
        │ in URLs to files whose styles you wish to fetch.           │
        │                                                            │
        │ * Figma URL look like so:                                  │
        │ https://www.figma.com/file/[fileID]/[fileName]             │
        └────────────────────────────────────────────────────────────┘
        """)

        let urlRegex = try NSRegularExpression(
            pattern: "^https\\:\\/\\/(www\\.)?figma\\.com\\/file\\/(.*?)(\\/(.*?))?$",
            options: .caseInsensitive
        )

        let files: [String] = UserInput(message: "🗳 Figma File URLs")
            .request(validatingResult: { possibleURL in
                let trimmed = possibleURL.trimmingCharacters(in: .whitespacesAndNewlines)

                guard let match = urlRegex.firstMatch(
                        in: trimmed,
                        options: .init(),
                        range: NSRange(location: 0, length: trimmed.utf16.count
                      )),
                      match.numberOfRanges == 3 || match.numberOfRanges == 5,
                      let range = Range(match.range(at: 2), in: trimmed) else {
                  return nil
                }

                return String(trimmed[range])
            })
        
        return .init(files: files)
    }
}
