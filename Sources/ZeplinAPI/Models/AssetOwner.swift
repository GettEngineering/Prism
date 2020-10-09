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
    case project(id: Project.ID)
    case styleguide(id: Styleguide.ID)

    public var id: String {
        switch self {
        case .project(let id),
             .styleguide(let id):
            return id
        }
    }

    public var description: String {
        switch self {
        case .project(let id): return "Project \(id)"
        case .styleguide(let id): return "Styleguide \(id)"
        }
    }
}
