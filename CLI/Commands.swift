//
//  Commands.swift
//  Prism
//
//  Created by Shai Mishali on 31/03/2019.
//

import Foundation
import Commander
import PrismCore

// MARK: - Generate to File Command
struct GenerateCommand: CommandRepresentable {
    struct Options: OptionsRepresentable {
        enum CodingKeys: String, CodingKeysRepresentable {
            case projectId
            case templatesPath
            case outputPath
        }

        static var keys: [Options.CodingKeys: Character] {
            return [.projectId: "i",
                    .templatesPath: "t",
                    .outputPath: "o"]
        }

        static var descriptions: [Options.CodingKeys : OptionDescription] {
            return [
                .projectId: .usage("Zeplin Project ID to generate text styles and colors from"),
                .templatesPath: .usage("Path to a folder containing *.prism template files"),
                .outputPath: .usage("Path to save generated files to")
            ]
        }

        let projectId: String
        let templatesPath: String
        let outputPath: String
    }

    static var symbol = "generate"
    static var usage = "Generate text style and colors definitions from a set of templates and store the resulting output to the provided paths"

    static func main(_ options: GenerateCommand.Options) throws {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw CommandError.missingToken
        }

        let prism = PrismAPI(jwtToken: jwtToken)
        let sema = DispatchSemaphore(value: 0)

        let templatesPath = options.templatesPath.last == "/" ? String(options.templatesPath.dropLast()) : options.templatesPath
        let outputPath = options.outputPath.last == "/" ? String(options.outputPath.dropLast()) : options.outputPath

        prism.getProject(id: options.projectId) { result in
            do {
                let project = try result.get()

                let allColorIdentities = Set(project.colors.flatMap { color in
                    Project.AssetIdentity.Style.allCases.map { $0.identifier(for: color.identity) }
                })
                let usedReservedColors = reservedColorNames.intersection(allColorIdentities)

                guard usedReservedColors.isEmpty else {
                    throw CommandError.prohibitedColorNames(colorNames: usedReservedColors.joined(separator: ", "))
                }

                let fileManager = FileManager.default
                let enumerator = fileManager.enumerator(atPath: templatesPath)

                guard fileManager.fileExists(atPath: templatesPath) else {
                    throw CommandError.templateFolderMissing(path: templatesPath)
                }

                var templateFiles = [String]()

                while let templateFile = enumerator?.nextObject() as? String {
                    guard !templateFile.hasPrefix("."),
                          templateFile.hasSuffix(".prism") else { continue }

                    templateFiles.append("\(templatesPath)/\(templateFile)")
                }

                guard !templateFiles.isEmpty else {
                    throw CommandError.noTemplateFiles
                }

                let parser = TemplateParser(project: project)

                for templateFile in templateFiles {
                    let template = try? String(contentsOfFile: templateFile)
                    let parsed = try! parser.parse(template: template ?? "")

                    let parsedData = parsed.data(using: .utf8) ?? Data()
                    let filename = templateFile.components(separatedBy: "/").last ?? ""
                    let outFile = String(filename.dropLast(6))
                    let outPath = "\(outputPath)/\(outFile)"

                    try parsedData.write(to: URL(fileURLWithPath: outPath))
                }

                sema.signal()
            } catch let err {
                print("Something went wrong: \(err)")
                exit(1)
            }
        }

        sema.wait()
    }
}

enum CommandError: Swift.Error, CustomStringConvertible {
    case invalidCommand
    case missingToken
    case failedDataConversion
    case prohibitedColorNames(colorNames: String)
    case templateFolderMissing(path: String)
    case noTemplateFiles

    var description: String {
        switch self {
        case .invalidCommand:
            return "Invalid command provided"
        case .missingToken:
            return "Missing ZEPLIN_TOKEN environment variable"
        case .failedDataConversion:
            return "Failed converting Data to unicode string"
        case .prohibitedColorNames(let colorNames):
            return "The following color names are reserved: \(colorNames)"
        case .templateFolderMissing(let path):
            return "The provided template folder doesn't exist: \(path)"
        case .noTemplateFiles:
            return "Can't find template files (*.prism) in provided folder"
        }
    }
}

#warning("Read these from external file")
/// A list of color names that are reserved by the Mobile OSs and cannot be used
/// for our custom color names.
private let reservedColorNames = Set([
    // iOS
    "black",
    "darkGray",
    "lightGray",
    "white",
    "gray",
    "red",
    "green",
    "blue",
    "cyan",
    "yellow",
    "magenta",
    "orange",
    "purple",
    "brown",
    "clear",

    // Android
    "main_dark",
    "black",
    "white",
    "yellow",
    "transparent_black_less_transparent",
    "alpha_white_background",
    "text_secondary",
    "text_primary",
    "divider",
    "item_list_divider",
    "text_blue",
    "text_blue_alpha",
    "gray",
    "transparent_full_black",
    "main_white",
    "main_white_transparent",
    "progress_bar_blue",
    "guid_c0",
    "guid_c1",
    "guid_c2",
    "guid_c3",
    "guid_c4",
    "guid_c5",
    "guid_c6",
    "guid_c7",
    "guid_c8",
    "guid_c9",
    "guid_c10",
    "guid_c11",
    "guid_c12",
    "guid_c13",
    "guid_c14",
    "guid_c15",
    "guid_c16",
    "guid_c17",
    "guid_c18",
    "guid_c19",
    "guid_c20",
    "guid_c21",
    "guid_c23",
    "guid_c24",
    "guid_c25",
    "guid_c26",
    "guid_c27",
    "guid_c28",
    "guid_c29",
    "guid_c30",
    "guid_c31",
    "guid_c32",
    "guid_c33",
    "guid_c35",
    "guid_c37",
    "guid_c38",
    "guid_c39",
    "guid_c40",
    "btn_orange_selector_state_disbale",
    "yellow_splash_progress",
    "splash_countries_text_color",
    "yellow_button_text",
    "yellow_button_loading",
    "top_driver_background",
    "blue_special",
    "grey_border",
    "coupon_overlay_background",
    "dark_blue_purple",
    "light_black",
    "list_divider",
    "secondary_address",
    "radar_blue",
    "transparent_white",
    "overlay_class_picker_transparent_black",
    "background_transparent_white",
    "drawer_divider",
    "manual_search_favorite_filter",
    "yellow_circle",
    "actionmode_background",
    "widget_background",
    "selector_white",
    "line_color",
    "line_color_disable",
    "line_subset_color",
    "invite_screen_invite_text",
    "coupon_sum_color",
    "surge_dialog_line_color",
    "surge_dialog_background_top_color",
    "region_disable_black",
    "region_background_image",
    "multi_pickup_msrker_label_text",
    "yellow_checked",
    "yellow_stroke_checked",
    "yellow_unchecked",
    "yellow_stroke_unchecked",
    "blue_enable",
    "leave_a_comment_cancel",
    "blue_disable",
    "ratingDivider",
    "email_registration_right_button_enabled",
    "email_registration_right_button_disabled",
    "loyalty_background",
    "loyalty_badge_text",
    "loyalty_unreached_badge",
    "loyalty_current_badge",
    "benefit_clicked",
    "upcomming_line_color",
    "polygon_stroke",
    "polygon_fill",
    "mandatory_pickup_separator",
    "grayish_white",
    "loading_progress_bar_yellow",
    "error_color",
    "hint_color",
    "status_bar",
    "overlay",
    "high_demand_eta",
    "navigation_menu_divider",
    "navigation_menu_loyalty_point",
    "navigation_menu_items",
    "credit_card_grey_text",
    "credit_card_hint_text",
    "credit_card_tint"
])
