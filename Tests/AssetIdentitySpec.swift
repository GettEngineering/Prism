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
            ].map(Prism.Project.AssetIdentity.init)

            context("iOS") {
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

                    expect(rawIdentities.map { $0.iOS } ) == expectedIdentities
                }
            }

            context("Android") {
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

                    expect(rawIdentities.map { $0.android } ) == expectedIdentities
                }
            }
        }

        describe("color identities") {
            context("iOS") {
                it("should return valid identities") {
                    let expectedIdentities = ["clearReddish", "blueSky"]

                    expect(self.project.colors.map { $0.identity.iOS }) == expectedIdentities
                }
            }

            context("Android") {
                it("should return valid identities") {
                    let expectedIdentities = ["clear_reddish", "blue_sky"]

                    expect(self.project.colors.map { $0.identity.android }) == expectedIdentities
                }
            }
        }

        describe("text style identities") {
            context("iOS") {
                it("should return valid identities") {
                    let expectedIdentities = ["largeHeading", "body"]

                    expect(self.project.textStyles.map { $0.identity.iOS }) == expectedIdentities
                }
            }

            context("Android") {
                it("should return valid identities") {
                    let expectedIdentities = ["large_heading", "body"]

                    expect(self.project.textStyles.map { $0.identity.android }) == expectedIdentities
                }
            }
        }
    }
}
