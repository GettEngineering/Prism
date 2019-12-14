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
    /// A Zeplin Project ID, represented by a `String`
    public typealias ID = String
    
    // Project ID
    public let id: ID
    
    // Project name
    public let name: String
    
    // Project description
    public let description: String?
    
    // Project platform (iOS, Android, Web, macOS)
    public let platform: Platform
    
    // Thumbnail URL
    public let thumbnail: URL?
    
    // Status (active, archived or deleted)
    public let status: Status
    
    // Scene URL
    public let sceneUrl: URL?
    
    // Creation date
    public let created: Date
    
    // Update date
    public let updated: Date?
    
    // Number of members for this project
    public let numberOfMembers: Int
    
    // Number of screens in this project
    public let numberOfScreens: Int
    
    // Number of components in this project
    public let numberOfComponents: Int
    
    // Number of text styles in this project
    public let numberOfTextStyles: Int
    
    // Number of colors in this project
    public let numberOfColors: Int
}

public extension Project {
    /// A platform for a specific Zeplin project
    enum Platform: String, CaseIterable, Codable {
        case web
        case ios
        case android
        case macos
    }
    
    /// The status of a Zeplin Project
    enum Status: String, CaseIterable, Codable {
        case active
        case archived
        case deleted
    }
}
