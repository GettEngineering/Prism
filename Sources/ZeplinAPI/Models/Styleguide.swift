//
//  Styleguide.swift
//  Prism
//
//  Created by Shai Mishali on 18/01/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// A Zeplin Stylguide
public struct Styleguide: Codable {
    public typealias ID = String
    
    /// Styleguide ID
    public let id: ID
    
    /// Styleguide Name
    public let name: String
    
    /// Styleguide platform
    public let platform: Project.Platform
    
    /// Styleguide status
    public let status: Project.Status
    
    /// Creation date
    public let created: Date
    
    /// Update date
    public let updated: Date
    
    /// Number of members for this syleguide
    public let numberOfMembers: Int
    
    /// Number of components in this styleguide
    public let numberOfComponents: Int
    
    /// Number of text styles in this styleguide
    public let numberOfTextStyles: Int
    
    /// Number of colors in this stylegide
    public let numberOfColors: Int
    
    /// Parent Stylguide ID, if exists
    public let parent: Styleguide.ID?
    
    private enum ParentKey: String, CodingKey {
        case id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.platform = try container.decode(Project.Platform.self, forKey: .platform)
        self.status = try container.decode(Project.Status.self, forKey: .status)
        self.created = try container.decode(Date.self, forKey: .created)
        self.updated = try container.decode(Date.self, forKey: .updated)
        self.numberOfMembers = try container.decode(Int.self, forKey: .numberOfMembers)
        self.numberOfComponents = try container.decode(Int.self, forKey: .numberOfComponents)
        self.numberOfTextStyles = try container.decode(Int.self, forKey: .numberOfTextStyles)
        self.numberOfColors = try container.decode(Int.self, forKey: .numberOfColors)
        
        if let parentContainer = try? container.nestedContainer(keyedBy: ParentKey.self, forKey: .parent) {
            self.parent = try parentContainer.decode(Styleguide.ID.self, forKey: .id)
        } else {
            self.parent = nil
        }
    }
}
