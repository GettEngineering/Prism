//
//  Zeplin+Prism.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import struct ZeplinAPI.Project
import class Foundation.FileManager

public extension Project.Platform {
    /// An emoji representing this platform
    var emoji: String {
        switch self {
        case .web:
            return "🌐"
        case .ios:
            return "📱"
        case .android:
            return "🤖"
        case .macos:
            return "💻"
        case .base:
            return "🎯"
        }
    }
    
    // Reserved colors for this platform
    var reservedColors: [String] {
        switch self {
        case .ios:
            return ["black", "darkGray", "lightGray", "white", "gray", "red", "green", "blue", "cyan", "yellow", "magenta", "orange", "purple", "brown", "clear"]
        default:
            return []
        }
    }
    
    // Read-friendly name for this platform
    var name: String {
        switch self {
        case .web:
            return "Web"
        case .ios:
            return "iOS"
        case .android:
            return "Android"
        case .macos:
            return "macOS"
        case .base:
            return "Base"
        }
    }
}
