//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public protocol ColorsFileProviding {
    func colorsFileContents(for colors: [Prism.Project.Color]) -> String
}

public protocol TextStylesFileProviding {
    func textStylesFileContents(for project: Prism.Project) -> String
}

public protocol StyleguideFileProviding: ColorsFileProviding, TextStylesFileProviding {
    var fileHeader: String { get }
}

public struct Styleguide {
    let provider: StyleguideFileProviding

    init(provider: StyleguideFileProviding) {
        self.provider = provider
    }
}
