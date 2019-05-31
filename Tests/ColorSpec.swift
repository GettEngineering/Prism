//
//  ColorSpec.swift
//  Prism
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation
import Quick
import Nimble
@testable import PrismCore

class ColorSpec: QuickSpec {
    override func spec() {
        let colors = [
            (255, 255, 255, 1),
            (0, 0, 0, 1),
            (100, 32, 78, 0.75),
            (4, 95, 123, 0.55),
            (71, 6, 23, 0.25),
            (51, 91, 210, 0)
        ].map(Project.RawColor.init)

        describe("rgbValue") {
            it("returns HEX RGB value") {
                let expectedRGB = [
                    "#ffffff",
                    "#000000",
                    "#64204e",
                    "#045f7b",
                    "#470617",
                    "#335bd2"
                ]

                expect(colors.map { $0.rgbValue }) == expectedRGB
            }
        }

        describe("argbValue") {
            it("Return HEX ARGB value") {
                let expectedARGB = [
                    "#ffffffff",
                    "#ff000000",
                    "#bf64204e",
                    "#8c045f7b",
                    "#40470617",
                    "#00335bd2"
                ]

                expect(colors.map { $0.argbValue }) == expectedARGB
            }
        }

        describe("identity(matching:)") {
            context("no color match") {
                it("should return nil") {
                    let projectResult = PrismAPI(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    let nonExistingColor = Project.RawColor(r: 255, g: 245, b: 200, a: 1.0)

                    expect(project.colors.identity(matching: nonExistingColor)).to(beNil())
                }
            }

            context("color matches") {
                it("should return correct color with identity") {
                    let projectResult = PrismAPI(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    let existingColors = [
                        Project.RawColor(r: 223, g: 99, b: 105, a: 0.79999995),
                        Project.RawColor(r: 98, g: 182, b: 223, a: 1.0)
                    ]

                    let matchingColors = existingColors.compactMap { project.colors.identity(matching: $0) }
                    let camelStyle = Project.AssetIdentity.Style.camelcase

                    expect(matchingColors.count) == 2
                    expect(camelStyle.identifier(for: matchingColors[0])) == "clearReddish"
                    expect(camelStyle.identifier(for: matchingColors[1])) == "blueSky"
                }
            }
        }
    }
}
