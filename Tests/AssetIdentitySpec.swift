//
//  AssetIdentitySpec.swift
//  PrismTests
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation
import Quick
import Nimble
@testable import PrismCore

class AssetIdentitySpec: QuickSpec {
    let project = try! Prism(jwtToken: "fake").mock(type: .successful).get()

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
            ].map(Project.AssetIdentity.init)

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

                    let processedIdentities = rawIdentities.map { Project.AssetIdentity.Style.camelcase.identifier(for: $0) }
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

                    let processedIdentities = rawIdentities.map { Project.AssetIdentity.Style.snakecase.identifier(for: $0) }
                    expect(processedIdentities) == expectedIdentities
                }
            }
        }

        describe("color identities") {
            context("camel case") {
                it("should return valid identities") {
                    let expectedIdentities = ["clearReddish", "blueSky"]
                    let proccessedIdentities = self.project.colors.map { Project.AssetIdentity.Style.camelcase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }

            context("snake case") {
                it("should return valid identities") {
                    let expectedIdentities = ["clear_reddish", "blue_sky"]
                    let proccessedIdentities = self.project.colors.map { Project.AssetIdentity.Style.snakecase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }
        }

        describe("text style identities") {
            context("camel case") {
                it("should return valid identities") {
                    let expectedIdentities = ["largeHeading", "body"]
                    let proccessedIdentities = self.project.textStyles.map { Project.AssetIdentity.Style.camelcase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }

            context("snake case") {
                it("should return valid identities") {
                    let expectedIdentities = ["large_heading", "body"]
                    let proccessedIdentities = self.project.textStyles.map { Project.AssetIdentity.Style.snakecase.identifier(for: $0.identity) }

                    expect(proccessedIdentities) == expectedIdentities
                }
            }
        }
    }
}
