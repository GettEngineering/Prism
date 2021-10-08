//
//  Utils.swift
//  Prism
//
//  Created by Shai Mishali on 17/04/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

#if os(Linux)
import Glibc
let os_exit: (Int32) -> Never = Glibc.exit
#elseif os(Windows)
import ucrt
let os_exit: (Int32) -> Never = ucrt.exit
#else
import Darwin
let os_exit: (Int32) -> Never = Darwin.exit
#endif

import Foundation

public func terminate(with message: String?) -> Never {
    if let message = message {
        print(message)
    }

    os_exit(1)
}

public extension String {
    func droppingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    func droppingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}

// MARK: - File Manager Helpers
public extension FileManager {
    func folderExists(at path: String) -> Bool {
        var isDir: ObjCBool = false
        return fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue
    }
}

// MARK: - Array Helpers
extension Array where Element: Hashable {
    /// Return a list of duplicates entires in a `Hashable` array
    func duplicates() -> Self {
        let groups = Dictionary(grouping: self, by: { $0 })
        let duplicateGroups = groups.filter { $1.count > 1 }
        let duplicates = Array(duplicateGroups.keys)
        return duplicates
    }
}

// MARK: - Result Helpers
extension Result {
    /// On a successful response, append the results into the provided results array pointer.
    /// On a failed response, append the error into the provided errors array pointer.
    ///
    /// - parameter values: Results array pointer
    /// - parameter errors: Errors array pointer
    func appendValuesOrErrors<Output>(values: inout [Output], errors: inout [Failure]) {
        switch self {
        case .success(let result):
            if let result = result as? [Output] {
                values.append(contentsOf: result)
            }

            if let result = result as? Output {
                values.append(result)
            }
        case .failure(let error):
            errors.append(error)
        }
    }
}

