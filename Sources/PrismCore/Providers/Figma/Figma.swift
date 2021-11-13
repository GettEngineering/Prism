//
//  File.swift
//  
//
//  Created by Shai Mishali on 04/10/2021.
//

import Foundation
import ProviderCore
import FigmaSwift

public struct Figma: AssetProviding {
    let api: FigmaSwift.FigmaAPI

    public static var provider: AssetProvider { .figma }

    public init(api: FigmaSwift.FigmaAPI) {
        self.api = api
    }
}

public extension Figma {
    enum Scope {
        case files(keys: [String])
    }
}

public extension Figma {
    func getAssets(
        for scope: Scope,
        completion: @escaping (Result<Assets, FigmaAPI.Error>) throws -> Void
    ) throws {
        // Files is the only available scope
        guard case .files(let keys) = scope else { return }

        var files = [File]()
        var errors = [FigmaAPI.Error]()
        let group = DispatchGroup()

        for key in keys {
            group.enter()

            api.getFile(key: key) { result in
                defer { group.leave() }
                result.appendValuesOrErrors(values: &files, errors: &errors)
            }
        }

        group.wait()

        guard errors.isEmpty else {
            try completion(.failure(.compoundError(errors: errors)))
            return
        }

        var colors = [ProviderCore.Color]()
        var textStyles = [ProviderCore.TextStyle]()
        
        for file in files {
            for (styleId, style) in file.styles {
                switch style.type {
                case .fill:
                    if let color = file.children.findColor(with: styleId) {
                        colors.append(
                            .init(
                                r: Int(color.r * 255),
                                g: Int(color.g * 255),
                                b: Int(color.b * 255),
                                a: color.a,
                                name: style.name
                            )
                        )
                    }
                case .text:
                    if let (typeStyle, color) = file.children.findTextStyle(with: styleId) {
                        let alignment: TextStyle.Alignment? = {
                            switch typeStyle.textAlignHorizontal {
                            case .left:
                                // Left alignment is the default in Figma, so
                                // it counts as "the lack of alignment" to align with Zeplin,
                                // as well as supporting "natural alignment" for RTL/LTR systems
                                return nil
                            case .right:
                                return .right
                            case .center:
                                return .center
                            case .justified:
                                return .justified
                            }
                        }()

                        textStyles.append(
                            .init(
                                name: style.name,
                                fontFamily: typeStyle.fontFamily,
                                fontPostscriptName: typeStyle.fontPostScriptName,
                                fontSize: typeStyle.fontSize,
                                fontWeight: Int(typeStyle.fontWeight),
                                fontStyle: "",
                                fontStretch: 0,
                                alignment: alignment,
                                lineHeight: nil,
                                lineSpacing: nil,
                                letterSpacing: typeStyle.letterSpacing,
                                color: .init(r: Int(color.r * 255),
                                             g: Int(color.g * 255),
                                             b: Int(color.b * 255),
                                             a: color.a,
                                             name: "")
                            )
                        )
                    }
                case .effect, .grid:
                    // Unsupported
                    continue
                }
            }
        }

        try completion(.success(.init(
            colors: colors,
            textStyles: textStyles,
            spacing: [] // Figma doesn't support spacing tokens
        )))
    }
}

// MARK: - Private Helpers
private extension Array where Element == Node {
    func findColor(with styleId: Style.ID) -> FigmaSwift.Color? {
        guard !isEmpty else { return nil }

        for node in self {
            if case .vector(let vector, _) = node,
               vector.styles[.fill] == styleId,
               let color = vector.fills.first?.color {
                return color
            }

            switch node {
            case .ellipse(let vector as VectorNodeType, _),
                 .rectangle(let vector as VectorNodeType, _),
                 .text(let vector as VectorNodeType, _),
                 .booleanOperation(let vector as VectorNodeType, _),
                 .instance(let vector as VectorNodeType, _),
                 .star(let vector as VectorNodeType, _),
                 .line(let vector as VectorNodeType, _),
                 .regularPolygon(let vector as VectorNodeType, _),
                 .vector(let vector as VectorNodeType, children: _):
                if vector.vector.styles[.fill] == styleId,
                   let color = vector.vector.fills.first?.color {
                    return color
                }
            case .canvas,
                    .frame,
                    .group,
                    .slice,
                    .component,
                    .componentSet:
                break
            }

            if let childMatch = node.children.findColor(with: styleId) {
                return childMatch
            }
        }

        return nil
    }

    /// Recursively match the first note which has a TEXT style matching the
    /// provided style ID. Then, return its type style and associated color info
    ///
    /// - paramter styleId: Figma Style ID (i.e. "31:44")
    ///
    /// - returns: An optional tuple of a Figma type style and a Color
    func findTextStyle(with styleId: Style.ID) -> (TypeStyle, FigmaSwift.Color)? {
        guard !isEmpty else { return nil }

        for node in self {
            if case .text(let text, _) = node,
               text.styles[.text] == styleId,
               let color = text.fills.first?.color {
                return (text.style, color)
            }

            if let childMatch = node.children.findTextStyle(with: styleId) {
                return childMatch
            }
        }

        return nil
    }
}
