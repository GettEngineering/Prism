//
//  File.swift
//  
//
//  Created by Shai Mishali on 03/10/2021.
//

import Foundation
import ProviderCore
import ZeplinSwift

// MARK: - Zeplin Model Conformances
extension ZeplinSwift.Color: RawColorRepresentable, AssetIdentifiable { }
extension ZeplinSwift.RawColor: RawColorRepresentable {}
extension ZeplinSwift.TextStyle: AssetIdentifiable {}
extension ZeplinSwift.Spacing: AssetIdentifiable {}

extension ProviderCore.Color {
    init(zeplinColor: ZeplinSwift.Color) {
        self.init(
            r: zeplinColor.r,
            g: zeplinColor.g,
            b: zeplinColor.b,
            a: zeplinColor.a,
            name: zeplinColor.name
        )
    }

    init(zeplinColor: ZeplinSwift.RawColor) {
        self.init(
            r: zeplinColor.r,
            g: zeplinColor.g,
            b: zeplinColor.b,
            a: zeplinColor.a,
            name: ""
        )
    }
}

extension ProviderCore.TextStyle.Alignment {
    init(zeplinAlignment: ZeplinSwift.TextStyle.Alignment) {
        switch zeplinAlignment {
        case .left:
            self = .left
        case .right:
            self = .right
        case .center:
            self = .center
        case .justified:
            self = .justified
        }
    }
}

extension ProviderCore.TextStyle {
    init(zeplinTextStyle: ZeplinSwift.TextStyle) {
        self.init(
            name: zeplinTextStyle.name,
            fontFamily: zeplinTextStyle.fontFamily,
            fontPostscriptName: zeplinTextStyle.postscriptName,
            fontSize: zeplinTextStyle.fontSize,
            fontWeight: zeplinTextStyle.fontWeight,
            fontStyle: zeplinTextStyle.fontStyle,
            fontStretch: zeplinTextStyle.fontStretch,
            alignment: zeplinTextStyle.textAlign.map { .init(zeplinAlignment: $0) },
            lineHeight: zeplinTextStyle.lineHeight,
            lineSpacing: zeplinTextStyle.lineSpacing,
            letterSpacing: zeplinTextStyle.letterSpacing,
            color: zeplinTextStyle.color.map { .init(zeplinColor: $0) }
        )
    }
}

extension ProviderCore.Spacing {
    init(zeplinSpacing: ZeplinSwift.Spacing) {
        self.init(
            id: zeplinSpacing.id,
            name: zeplinSpacing.name,
            value: zeplinSpacing.value,
            color: .init(zeplinColor: zeplinSpacing.color)
        )
    }
}
