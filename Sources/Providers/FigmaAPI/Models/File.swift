//
//  File.swift
//  Prism
//
//  Created by Shai Mishali on 01/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation

public struct File: Decodable {
    public let styles: [Style.ID: Style]
    public let name: String
    public let lastModified: Date
    public let thumbnailUrl: URL
    public let version: String
    public let role: String
    public let editorType: String
    public let children: [Node]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.styles = try container.decode(.styles)
        self.name = try container.decode(.name)
        self.lastModified = try container.decode(.lastModified)
        self.thumbnailUrl = try container.decode(.thumbnailUrl)
        self.version = try container.decode(.version)
        self.role = try container.decode(.role)
        self.editorType = try container.decode(.editorType)

        let documentContainer = try container.nestedContainer(keyedBy: DocumentKeys.self, forKey: .document)
        self.children = try documentContainer.decode(.children)
    }

    enum CodingKeys: CodingKey {
        case document
        case styles
        case name
        case lastModified
        case thumbnailUrl
        case version
        case role
        case editorType
    }

    enum DocumentKeys: CodingKey {
        case children
    }
}
