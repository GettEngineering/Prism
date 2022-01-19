//
//  Node.swift
//  Prism
//
//  Created by Shai Mishali on 15/11/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

indirect public enum Node: Decodable {
    case canvas(Canvas, children: [Node])
    case frame(Frame, children: [Node])
    case group(Group, children: [Node])
    case vector(Vector, children: [Node])
    case booleanOperation(BooleanOperation, children: [Node])
    case star(Star, children: [Node])
    case line(Line, children: [Node])
    case ellipse(Ellipse, children: [Node])
    case regularPolygon(Vector, children: [Node])
    case rectangle(Rectangle, children: [Node])
    case text(Text, children: [Node])
    case slice(Slice, children: [Node])
    case component(Component, children: [Node])
    case componentSet(ComponentSet, children: [Node])
    case instance(Instance, children: [Node])

    enum CodingKeys: String, CodingKey {
        case type
        case children
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let children = try container.decodeIfPresent([Node].self, forKey: .children) ?? []
        let singleContainer = try decoder.singleValueContainer()

        switch type.lowercased() {
        case "canvas":
            self = .canvas(try singleContainer.decode(Canvas.self), children: children)
        case "frame":
            self = .frame(try singleContainer.decode(Frame.self), children: children)
        case "group":
            self = .group(try singleContainer.decode(Frame.self), children: children)
        case "vector":
            self = .vector(try singleContainer.decode(Vector.self), children: children)
        case "boolean_operation":
            self = .booleanOperation(try singleContainer.decode(BooleanOperation.self), children: children)
        case "star":
            self = .star(try singleContainer.decode(Star.self), children: children)
        case "line":
            self = .line(try singleContainer.decode(Line.self), children: children)
        case "ellipse":
            self = .ellipse(try singleContainer.decode(Ellipse.self), children: children)
        case "regular_polygon":
            self = .regularPolygon(try singleContainer.decode(RegularPolygon.self), children: children)
        case "rectangle":
            self = .rectangle(try singleContainer.decode(Rectangle.self), children: children)
        case "text":
            self = .text(try singleContainer.decode(Text.self), children: children)
        case "slice":
            self = .slice(try singleContainer.decode(Slice.self), children: children)
        case "component":
            self = .component(try singleContainer.decode(Component.self), children: children)
        case "component_set":
            self = .componentSet(try singleContainer.decode(ComponentSet.self), children: children)
        case "instance":
            self = .instance(try singleContainer.decode(Instance.self), children: children)
        default:
            throw DecodingError.typeMismatch(
                Node.self,
                .init(
                    codingPath: [],
                    debugDescription: "Unknown node of type '\(type)'",
                    underlyingError: nil
                )
            )
        }
    }

    public var children: [Node] {
        switch self {

        case .canvas(_, let children),
             .frame(_, let children),
             .group(_, let children),
             .vector(_, let children),
             .booleanOperation(_, let children),
             .star(_, let children),
             .line(_, let children),
             .ellipse(_, let children),
             .regularPolygon(_, let children),
             .rectangle(_, let children),
             .text(_, let children),
             .slice(_, let children),
             .component(_, let children),
             .componentSet(_, let children),
             .instance(_, let children):
            return children
        }
    }
}
