//
//  Zeplin+Prism.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import struct ZeplinSwift.Project
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
