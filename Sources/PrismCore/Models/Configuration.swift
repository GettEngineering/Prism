//
//  Configuration.swift
//  Prism
//
//  Created by Shai Mishali on 31/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public struct Configuration {
    /// Zeplin Project ID
    public let projectId: String?

    /// Zeplin Styleguide ID
    public let styleguideId: String?
    
    /// Path to look for *.prism templates in
    public let templatesPath: String?
    
    /// Path to output the result of template processing to
    public let outputPath: String?
    
    /// A list of reserved color identities that cannot be used.
    public let reservedColors: [String]

    /// A list of reserved text style identities that cannot be used.
    public let reservedTextStyles: [String]

    /// A list of ignored Style Guide IDs, that will not be fetched.
    public let ignoredStyleGuides: [String]
}

extension Configuration: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.projectId = try? container.decode(String.self, forKey: .projectId)
        self.styleguideId = try? container.decode(String.self, forKey: .styleguideId)
        self.templatesPath = try? container.decode(String.self, forKey: .templatesPath)
        self.outputPath = try? container.decode(String.self, forKey: .outputPath)
        self.reservedColors = (try? container.decode([String].self, forKey: .reservedColors)) ?? []
        self.reservedTextStyles = (try? container.decode([String].self, forKey: .reservedTextStyles)) ?? []
        self.ignoredStyleGuides = (try? container.decode([String].self, forKey: .ignoredStyleGuides)) ?? []
    }
    
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case styleguideId = "styleguide_id"
        case templatesPath = "templates_path"
        case outputPath = "output_path"
        case reservedColors = "reserved_colors"
        case reservedTextStyles = "reserved_textstyles"
        case ignoredStyleGuides = "ignored_styleguides"
    }
}
