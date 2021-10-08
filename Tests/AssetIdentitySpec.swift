//
//  AssetIdentitySpec.swift
//  PrismTests
//
//  Created by Shai Mishali on 23/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import PrismCore
@testable import ZeplinSwift

class AssetIdentitySpec: QuickSpec {
    let project = try! Prism(jwtToken: "fake").mock(type: .successfulProject).get()

    override func spec() {
        describe("raw identities") {
            let rawIdentities = [
                "A great color",
                "Sky Red",
                "Title M Regular",
                "Accent Blue",
                "PrimaryRed",
                "My Color 2",
                "My Color3",
                "My-Awesome_Color"
            ].map(AssetIdentity.init)

            context("camel case") {
                it("should return camel-cased identities") {
                    let expectedIdentities = [
                        "aGreatColor",
                        "skyRed",
                        "titleMRegular",
                        "accentBlue",
                        "primaryRed",
                        "myColor2",
                        "myColor3",
                        "myAwesomeColor"
                    ]

                    let processedIdentities = rawIdentities.map { AssetIdentity.Style.camelcase.identifier(for: $0) }
                    expect(processedIdentities) == expectedIdentities
                }
            }

            context("snake case") {
                it("should return lowercased identities with underscores") {
                    let expectedIdentities = [
                        "a_great_color",
                        "sky_red",
                        "title_m_regular",
                        "accent_blue",
                        "primary_red",
                        "my_color_2",
                        "my_color3",
                        "my_awesome_color"
                    ]

                    let processedIdentities = rawIdentities.map { AssetIdentity.Style.snakecase.identifier(for: $0) }
                    expect(processedIdentities) == expectedIdentities
                }
            }

            context("kebab case") {
                it("should return lowercased identities with dashes") {
                    let expectedIdentities = [
                        "a-great-color",
                        "sky-red",
                        "title-m-regular",
                        "accent-blue",
                        "primary-red",
                        "my-color-2",
                        "my-color3",
                        "my-awesome-color"
                    ]

                    let processedIdentities = rawIdentities.map { AssetIdentity.Style.kebabcase.identifier(for: $0) }
                    expect(processedIdentities) == expectedIdentities
                }
            }

            context("pascal case") {
                it("should return pascal-cased identities") {
                    let expectedIdentities = [
                        "AGreatColor",
                        "SkyRed",
                        "TitleMRegular",
                        "AccentBlue",
                        "PrimaryRed",
                        "MyColor2",
                        "MyColor3",
                        "MyAwesomeColor"
                    ]

                    let processedIdentities = rawIdentities.map { AssetIdentity.Style.pascalcase.identifier(for: $0) }
                    expect(processedIdentities) == expectedIdentities
                }
            }
        }

        describe("color identities") {
            context("camel case") {
                it("should return valid identities") {
                    let expectedIdentities = ["blueSky", "clearReddish", "blue", "green", "mud", "purple", "red", "teal"]
                    let proccessedIdentities = self.project.colors.map { AssetIdentity.Style.camelcase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }

            context("snake case") {
                it("should return valid identities") {
                    let expectedIdentities = ["blue_sky", "clear_reddish", "blue", "green", "mud", "purple", "red", "teal"]
                    let proccessedIdentities = self.project.colors.map { AssetIdentity.Style.snakecase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }
        }

        describe("text style identities") {
            context("camel case") {
                it("should return valid identities") {
                    let expectedIdentities = ["baseHeading", "baseSubhead", "body", "body2", "highlight", "largeHeading", "homeSubInnerPrimary300L"]
                    let proccessedIdentities = self.project.textStyles.map { AssetIdentity.Style.camelcase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }

            context("snake case") {
                it("should return valid identities") {
                    let expectedIdentities = ["base_heading", "base_subhead", "body", "body_2", "highlight", "large_heading", "home_sub_inner_primary_300_l"]
                    let proccessedIdentities = self.project.textStyles.map { AssetIdentity.Style.snakecase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }
        }
        
        describe("empty identity") {
            it("should return empty identities") {
                let identity = AssetIdentity(name: "")
                
                let all = AssetIdentity.Style.allCases.map { $0.identifier(for: identity) }
                expect(all.allSatisfy { $0 == "" }).to(beTrue())
            }
        }
    }
}
