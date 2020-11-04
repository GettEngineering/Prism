//
//  ConfigurationSpec.swift
//  PrismTests
//
//  Created by Shai Mishali on 01/06/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Yams

@testable import PrismCore

class ConfigurationSpec: QuickSpec {
    override func spec() {
        describe("decode") {
            context("empty") {
                it("should build empty configuration") {
                    let decoder = YAMLDecoder()
                    let yaml = """
                    fake_config: "ok"
                    """

                    let config = try! decoder.decode(PrismCore.Configuration.self,
                                                     from: yaml)

                    expect(config.reservedColors).to(beEmpty())
                    expect(config.reservedTextStyles).to(beEmpty())
                }
            }

            context("full") {
                it("should build proper configuration") {
                    let decoder = YAMLDecoder()
                    let yaml = """
                    reserved_colors:
                        - fake1
                        - fake2
                    reserved_textstyles:
                        - fake3
                        - fake4
                    ignored_style_guides_ids:
                        - "12"
                        - "13"
                    """
                    let config = try! decoder.decode(PrismCore.Configuration.self,
                                                     from: yaml)

                    expect(config.ignoredStyleGuideIds) == ["12", "13"]
                    expect(config.reservedColors) == ["fake1", "fake2"]
                    expect(config.reservedTextStyles) == ["fake3", "fake4"]
                }
            }
        }
    }
}
