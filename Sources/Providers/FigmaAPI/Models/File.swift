//
//  File.swift
//  
//
//  Created by Shai Mishali on 01/10/2021.
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
        case "regularPolygon":
            self = .regularPolygon(try singleContainer.decode(RegularPolygon.self), children: children)
        case "rectangle":
            self = .rectangle(try singleContainer.decode(Rectangle.self), children: children)
        case "text":
            self = .text(try singleContainer.decode(Text.self), children: children)
        case "slice":
            self = .slice(try singleContainer.decode(Slice.self), children: children)
        case "component":
            self = .component(try singleContainer.decode(Component.self), children: children)
        case "componentSet":
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

public extension Node {
    struct Canvas: Decodable {
        public let backgroundColor: Color
        public let flowStartingPoints: [FlowStartingPoint]
    }

    typealias Star = Vector
    typealias Line = Vector
    typealias Component = Frame
    typealias ComponentSet = Frame
    typealias Group = Frame
    typealias RegularPolygon = Vector

    @dynamicMemberLookup
    struct Ellipse: VectorNodeType, Decodable {
        public let vector: Vector
        public let arcData: ArcData

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.arcData = try container.decode(.arcData)
        }

        enum CodingKeys: String, CodingKey {
            case arcData
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }
    }

    @dynamicMemberLookup
    struct Rectangle: VectorNodeType, Decodable {
        public let vector: Vector
        public let cornerRadius: Float
        public let rectangleCornerRadii: [Float]

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.cornerRadius = try container.decodeIfPresent(.cornerRadius) ?? 0
            self.rectangleCornerRadii = try container.decodeIfPresent(.rectangleCornerRadii) ?? Array(repeating: cornerRadius, count: 4)
        }

        enum CodingKeys: String, CodingKey {
            case cornerRadius, rectangleCornerRadii
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }
    }

    @dynamicMemberLookup
    struct Text: VectorNodeType, Decodable {
        public let vector: Vector
        public let characters: String
        public let style: TypeStyle

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.characters = try container.decode(.characters)
            self.style = try container.decode(.style)
        }

        enum CodingKeys: String, CodingKey {
            case characters, style
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }

        public enum Case: String, Decodable {
            case original = "ORIGINAL"
            case uppercase = "UPPER"
            case lowercase = "LOWER"
            case titlecase = "TITLE"
            case smallCaps = "SMALL_CAPS"
            case smallCapsForced = "SMALL_CAPS_FORCED"
        }

        public enum Decoration: String, Decodable {
            case none = "NONE"
            case strikethrough = "STRIKETHROUGH"
            case underline = "UNDERLINE"
        }

        public enum Autoresize: String, Decodable {
            case none = "NONE"
            case height = "HEIGHT"
            case widthAndHeight = "WIDTH_AND_HEIGHT"
        }

        public enum HorizontalAlignment: String, Decodable {
            case left = "LEFT"
            case right = "RIGHT"
            case center = "CENTER"
            case justified = "JUSTIFIED"
        }

        public enum VerticalAlignment: String, Decodable {
            case top = "TOP"
            case center = "CENTER"
            case bottom = "BOTTOM"
        }
    }

    struct Slice: Decodable {
        public let absoluteBoundingBox: Box
        public let size: Size
    }

    @dynamicMemberLookup
    struct BooleanOperation: VectorNodeType, Decodable {
        public let vector: Vector
        public let operation: Operation

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.operation = try container.decode(.booleanOperation)
        }

        enum CodingKeys: String, CodingKey {
            case booleanOperation
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }

        public enum Operation: String, Decodable {
            case union = "UNION"
            case intersect = "INTERSECT"
            case subtract = "SUBTRACT"
            case exclude = "EXCLUDE"
        }
    }

    @dynamicMemberLookup
    struct Instance: VectorNodeType, Decodable {
        public let vector: Vector
        public let componentId: String

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.vector = try decoder.singleValueContainer().decode(Vector.self)
            self.componentId = try container.decode(.componentId)
        }

        public enum CodingKeys: String, CodingKey {
            case componentId
        }

        public subscript<T>(dynamicMember keyPath: KeyPath<Vector, T>) -> T {
            vector[keyPath: keyPath]
        }
    }

    struct Frame: Decodable {
        public let locked: Bool
        public let fills: [Paint]
        public let strokes: [Paint]
        public let strokeWeight: Float
        public let strokeAlign: StrokeAlign
        public let cornerRadius: Float
        public let rectangleCornerRadiiNumber: [Float]
        public let blendingMode: BlendingMode
        public let shouldPreserveRatio: Bool
        public let constraints: AxisConstraints
        public let opacity: Float
        public let absoluteBoundingBox: Box
        public let size: Size
        public let clipsContent: Bool
        public let layoutMode: LayoutMode
        public let paddingLeft: Float
        public let paddingRight: Float
        public let paddingBottom: Float
        public let paddingTop: Float
        public let horizontalPadding: Float
        public let verticalPadding: Float
        public let itemSpacing: Float

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.locked = try container.decodeIfPresent(.locked) ?? false
            self.fills = try container.decodeIfPresent(.fills) ?? []
            self.strokes = try container.decodeIfPresent(.strokes) ?? []
            self.strokeWeight = try container.decode(.strokeWeight)
            self.strokeAlign = try container.decode(.strokeAlign)
            self.cornerRadius = try container.decodeIfPresent(.cornerRadius) ?? 0
            self.rectangleCornerRadiiNumber = try container.decodeIfPresent(.rectangleCornerRadiiNumber) ?? Array(repeating: cornerRadius, count: 4)
            self.blendingMode = try container.decode(.blendMode)
            self.shouldPreserveRatio = try container.decodeIfPresent(.preserveRatio) ?? false
            self.constraints = try container.decode(.constraints)
            self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0
            self.absoluteBoundingBox = try container.decodeIfPresent(.absoluteBoundingBox) ?? .zero
            self.size = try container.decodeIfPresent(.size) ?? .zero
            self.clipsContent = try container.decode(.clipsContent)
            self.layoutMode = try container.decodeIfPresent(.layoutMode) ?? .none
            self.paddingLeft = try container.decodeIfPresent(.paddingLeft) ?? 0
            self.paddingRight = try container.decodeIfPresent(.paddingRight) ?? 0
            self.paddingBottom = try container.decodeIfPresent(.paddingBottom) ?? 0
            self.paddingTop = try container.decodeIfPresent(.paddingTop) ?? 0
            self.horizontalPadding = try container.decodeIfPresent(.horizontalPadding) ?? 0
            self.verticalPadding = try container.decodeIfPresent(.verticalPadding) ?? 0
            self.itemSpacing = try container.decodeIfPresent(.itemSpacing) ?? 0
        }

        enum CodingKeys: String, CodingKey {
            case locked,
                 fills,
                 strokes,
                 strokeWeight,
                 strokeAlign,
                 cornerRadius,
                 rectangleCornerRadiiNumber,
                 blendMode,
                 preserveRatio,
                 constraints,
                 opacity,
                 absoluteBoundingBox,
                 size,
                 clipsContent,
                 layoutMode,
                 paddingLeft,
                 paddingRight,
                 paddingBottom,
                 paddingTop,
                 horizontalPadding,
                 verticalPadding,
                 itemSpacing
        }
    }

    struct Vector: Decodable, VectorNodeType {
        public let isLocked: Bool
        public let blendingMode: BlendingMode
        public let shouldPreserveRatio: Bool
        public let constraints: AxisConstraints
        public let opacity: Float
        public let absoluteBoundingBox: Box
        public let effects: [Effect]
        public let size: Size
        public let isMask: Bool
        public let fills: [Paint]
        public let strokes: [Paint]
        public let strokeWeight: Float
        public let strokeCap: StrokeCap
        public let strokeJoin: StrokeJoin
        public let strokeDashes: [Float]
        public let strokeMiterAngle: Float
        public let strokeAlign: StrokeAlign
        public let styles: [Style.Kind: Style.ID]

        public var vector: Vector { self }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.isLocked = try container.decodeIfPresent(.locked) ?? false
            self.blendingMode = try container.decode(.blendMode)
            self.shouldPreserveRatio = try container.decodeIfPresent(.preserveRatio) ?? false
            self.constraints = try container.decode(.constraints)
            self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0
            self.absoluteBoundingBox = try container.decodeIfPresent(.absoluteBoundingBox) ?? .zero
            self.effects = try container.decodeIfPresent(.effects) ?? []
            self.size = try container.decodeIfPresent(.size) ?? .zero
            self.isMask = try container.decodeIfPresent(.isMask) ?? false
            self.fills = try container.decodeIfPresent(.fills) ?? []
            self.strokes = try container.decodeIfPresent(.strokes) ?? []
            self.strokeWeight = try container.decode(.strokeWeight)
            self.strokeCap = try container.decodeIfPresent(.strokeCap) ?? .none
            self.strokeJoin = try container.decodeIfPresent(.strokeJoin) ?? .miter
            self.strokeDashes = try container.decodeIfPresent(.strokeDashes) ?? []
            self.strokeMiterAngle = try container.decodeIfPresent(.strokeMiterAngle) ?? 28.96
            self.strokeAlign = try container.decode(.strokeAlign)
            let rawStyles = try container.decodeIfPresent([String: String].self, forKey: .styles) ?? [:]
            self.styles = rawStyles.reduce(into: [Style.Kind: Style.ID]()) { output, kv in
                guard let kind = Style.Kind(rawValue: kv.key) else { return }
                output[kind] = kv.value
            }
        }

        enum CodingKeys: String, CodingKey {
            case locked,
                 blendMode,
                 preserveRatio,
                 constraints,
                 opacity,
                 absoluteBoundingBox,
                 effects,
                 size,
                 isMask,
                 fills,
                 strokes,
                 strokeWeight,
                 strokeCap,
                 strokeJoin,
                 strokeDashes,
                 strokeMiterAngle,
                 strokeAlign,
                 styles
        }
    }

    struct ArcData: Decodable {
        public let startingAngle: Float
        public let endingAngle: Float
        public let innerRadius: Float
    }
}

public enum Hyperlink: Decodable {
    case url(URL)
    case node(String)

    enum CodingKeys: String, CodingKey {
        case url
        case nodeID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let nodeID = try? container.decode(String.self, forKey: .nodeID) {
            self = .node(nodeID)
        }

        self = .url(try container.decode(URL.self, forKey: .url))
    }
}

public struct TypeStyle: Decodable {
    public let fontFamily: String
    public let fontPostScriptName: String
    public let paragraphSpacing: Float
    public let paragraphIndent: Float
    public let italic: Bool
    public let fontWeight: Float
    public let fontSize: Float
    public let textCase: Node.Text.Case
    public let textDecoration: Node.Text.Decoration
    public let textAutoResize: Node.Text.Autoresize
    public let textAlignHorizontal: Node.Text.HorizontalAlignment
    public let textAlignVertical: Node.Text.VerticalAlignment
    public let letterSpacing: Float
    public let fills: [Paint]
    public let hyperlink: Hyperlink?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fontFamily = try container.decode(.fontFamily)
        self.fontPostScriptName = try container.decode(.fontPostScriptName)
        self.paragraphSpacing = try container.decodeIfPresent(.paragraphSpacing) ?? 0
        self.paragraphIndent = try container.decodeIfPresent(.paragraphIndent) ?? 0
        self.italic = try container.decodeIfPresent(.italic) ?? false
        self.fontWeight = try container.decode(.fontWeight)
        self.fontSize = try container.decode(.fontSize)
        self.textCase = try container.decodeIfPresent(.textCase) ?? .original
        self.textDecoration = try container.decodeIfPresent(.textDecoration) ?? .none
        self.textAutoResize = try container.decodeIfPresent(.textAutoResize) ?? .none
        self.textAlignHorizontal = try container.decode(.textAlignHorizontal)
        self.textAlignVertical = try container.decode(.textAlignVertical)
        self.letterSpacing = try container.decode(.letterSpacing)
        self.fills = try container.decodeIfPresent(.fills) ?? []
        self.hyperlink = try container.decodeIfPresent(.hyperlink)
    }

    enum CodingKeys: String, CodingKey {
        case fontFamily,
             fontPostScriptName,
             paragraphSpacing,
             paragraphIndent,
             italic,
             fontWeight,
             fontSize,
             textCase,
             textDecoration,
             textAutoResize,
             textAlignHorizontal,
             textAlignVertical,
             letterSpacing,
             fills,
             hyperlink
    }
}

public enum StrokeCap: String, Decodable {
    case none = "NONE"
    case round = "ROUND"
    case square = "SQUARE"
    case lineArrow = "LINE_ARROW"
    case triangleArrow = "TRIANGLE_ARROW"
}

public enum StrokeJoin: String, Decodable {
    case miter = "MITER"
    case bevel = "BEVEL"
    case round = "ROUND"
}

public struct Effect: Decodable {
    public let type: Kind
    public let isVisible: Bool
    public let radius: Float
    public let color: Color
    public let blendMode: BlendingMode
    public let offset: Point
    public let spread: Float
    public let showShadowBehindNode: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(.type)
        self.isVisible = try container.decodeIfPresent(.visible) ?? true
        self.radius = try container.decode(.radius)
        self.color = try container.decode(.color)
        self.blendMode = try container.decode(.blendMode)
        self.offset = try container.decode(.offset)
        self.spread = try container.decodeIfPresent(.spread) ?? 0
        self.showShadowBehindNode = try container.decodeIfPresent(.showShadowBehindNode) ?? false
    }

    enum CodingKeys: String, CodingKey {
        case type,
             visible,
             radius,
             color,
             blendMode,
             offset,
             spread,
             showShadowBehindNode
    }

    public enum Kind: String, Decodable {
        case innerShadow = "INNER_SHADOW"
        case dropShadow = "DROP_SHADOW"
        case layerBlur = "LAYER_BLUR"
        case backgroundBlur = "BACKGROUND_BLUR"
    }
}

public enum LayoutMode: String, Decodable {
    case none = "NONE"
    case horizontal = "HORIZONTAL"
    case vertical = "VERTICAL"
}

public struct AxisConstraints: Decodable {
    public let vertical: LayoutConstraint
    public let horizontal: LayoutConstraint
}

public enum LayoutConstraint: String, Decodable {
    // Vertical
    case top = "TOP"
    case bottom = "BOTTOM"
    case topBottom = "TOP_BOTTOM"

    // Horizontal
    case left = "LEFT"
    case right = "RIGHT"
    case leftRight = "LEFT_RIGHT"

    // Both
    case center = "CENTER"
    case scale = "SCALE"
}

public enum StrokeAlign: String, Decodable {
    case inside = "INSIDE"
    case outside = "OUTSIDE"
    case center = "CENTER"
}

public struct Paint: Decodable {
    public let type: Kind
    public let isVisible: Bool
    public let opacity: Float
    public let color: Color?
    public let blendingMode: BlendingMode
    public let gradientHandlePositions: [CGPoint]
    public let gradientStops: [ColorStop]
    public let scaleMode: ScaleMode

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(.type)
        self.isVisible = try container.decodeIfPresent(.visible) ?? true
        self.opacity = try container.decodeIfPresent(.opacity) ?? 1.0
        self.color = try container.decodeIfPresent(.color)
        self.blendingMode = try container.decode(.blendMode)
        self.gradientHandlePositions = try container.decodeIfPresent(.gradientHandlePositions) ?? []
        self.gradientStops = try container.decodeIfPresent(.gradientStops) ?? []
        self.scaleMode = try container.decodeIfPresent(.scaleMode) ?? .fill
    }

    enum CodingKeys: String, CodingKey {
        case type,
             visible,
             opacity,
             color,
             blendMode,
             gradientHandlePositions,
             gradientStops,
             scaleMode
    }

    public enum Kind: String, Decodable {
        case solid = "SOLID"
        case linearGradient = "GRADIENT_LINEAR"
        case radialGradient = "GRADIENT_RADIAL"
        case angularGradient = "GRADIENT_ANGULAR"
        case diamongGradient = "GRADIENT_DIAMOND"
        case image = "IMAGE"
        case emoji = "EMOJI"
    }
}

public enum ScaleMode: String, Decodable {
    case fill = "FILL"
    case fit = "FIT"
    case tile = "TILE"
    case stretch = "STRETCH"
}

public struct ColorStop: Decodable {
    let position: Float
    let color: Color
}

public enum BlendingMode: String, Decodable {
    case passThrough = "PASS_THROUGH"
    case normal = "NORMAL"

    // Darken
    case darken = "DARKEN"
    case multiply = "MULTIPLY"
    case linearBurn = "LINEAR_BURN"
    case colorBurn = "COLOR_BURN"

    // Lighten
    case lighten = "LIGHTEN"
    case screen = "SCREEN"
    case linearDodge = "LINEAR_DODGE"
    case colorDodge = "COLOR_DODGE"

    // Contrast
    case overlay = "OVERLAY"
    case softLight = "SOFT_LIGHT"
    case hardLight = "HARD_LIGHT"

    // Inversion
    case difference = "DIFFERENCE"
    case exclusion = "EXCLUSION"

    // Component
    case hue = "HUE"
    case saturation = "SATURATION"
    case color = "COLOR"
    case luminosity = "LUMINOSITY"
}

public extension Node.Canvas {
    struct FlowStartingPoint: Decodable {
        let noteId: String
        let name: String
    }
}

public enum Format: String, Decodable {
    case jpg = "JPG"
    case png = "PNG"
    case svg = "SVG"
}

public struct Color: Decodable {
    public let r: Float
    public let g: Float
    public let b: Float
    public let a: Float
}

public extension KeyedDecodingContainer {
    func decodeIfPresent<T>(_ key: KeyedDecodingContainer.Key) throws -> T? where T: Decodable {
        return try self.decodeIfPresent(T.self, forKey: key)
    }

    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try self.decode(T.self, forKey: key)
    }
}

public struct Box: Decodable {
    public let x: Float
    public let y: Float
    public let width: Float
    public let height: Float

    public var point: Point { .init(x: x, y: y) }
    public var size: Size { .init(width: width, height: height) }

    static public var zero: Self { .init(x: 0, y: 0, width: 0, height: 0) }
}

public struct Size: Decodable {
    public let width: Float
    public let height: Float

    public static var zero: Self { .init(width: 0, height: 0) }
}

public struct Point: Decodable {
    public let x: Float
    public let y: Float

    public static var zero: Self { .init(x: 0, y: 0) }
}

public protocol VectorNodeType {
    var vector: Node.Vector { get }
}
