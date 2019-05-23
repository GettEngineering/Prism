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
        ].map(Prism.Project.RawColor.init)

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
    }
}
