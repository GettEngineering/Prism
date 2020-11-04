//
//  AssetOwner.swift
//  Prism
//
//  Created by Shai Mishali on 09/10/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// An asset owner: either a Project or a Styleguide
public enum AssetOwner: Equatable, CustomStringConvertible {
    case project(id: Project.ID, ignoredStyleGuideIds: [String])
    case styleguide(id: Styleguide.ID)

    public static func project(id: Project.ID) -> Self {
        .project(id: id, ignoredStyleGuideIds: [])
    }

    public var id: String {
        switch self {
        case .project(let id, _),
             .styleguide(let id):
            return id
        }
    }

    public var ignoredStyleGuideIds: [String] {
        switch  self {
        case .project(_, let ignoredStyleGuideIds):
            return ignoredStyleGuideIds

        default:
            return []
        }
    }

    public var description: String {
        switch self {
        case .project(let id, _): return "Project \(id)"
        case .styleguide(let id): return "Styleguide \(id)"
        }
    }
}
