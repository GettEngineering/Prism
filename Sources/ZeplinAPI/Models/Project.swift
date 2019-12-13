//
//  Project.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

// A Zeplin Project
public struct Project: Codable {
    public typealias ID = String
    
    // Project ID
    let id: ID
    
    // Project name
    let name: String
    
    // Project description
    let description: String?
    
    // Project platform (iOS, Android, Web, macOS)
    let platform: Platform
    
    // Thumbnail URL
    let thumbnail: URL?
    
    // Status (active, archived or deleted)
    let status: Status
    
    // Scene URL
    let sceneUrl: URL?
    
    // Creation date
    let created: Date
    
    // Update date
    let updated: Date?
    
    // Number of members for this project
    let numberOfMembers: Int
    
    // Number of screens in this project
    let numberOfScreens: Int
    
    // Number of components in this project
    let numberOfComponents: Int
    
    // Number of text styles in this project
    let numberOfTextStyles: Int
    
    // Number of colors in this project
    let numberOfColors: Int
}

public extension Project {
    /// A platform for a specific Zeplin project
    enum Platform: String, Codable {
        case web
        case ios
        case android
        case macos
    }
    
    /// The status of a Zeplin Project
    enum Status: String, Codable {
        case active
        case archived
        case deleted
    }
}
