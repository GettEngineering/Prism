//
//  AssetsSpec.swift
//  Prism
//
//  Created by Shai Mishali on 22/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SnapshotTesting
@testable import PrismCore
@testable import ZeplinAPI

class AssetsSpec: QuickSpec {
    override func spec() {
        describe("assets snapshot") {
            it("is valid") {
                let assetsResult = Prism(jwtToken: "fake").mock(type: .successfulProject)
                let assets = try! assetsResult.get()

                assertSnapshot(matching: "\(assets.debugDescription)",
                               as: .lines,
                               named: "assets snapshot is valid")
            }
        }

        describe("failed server response") {
            it("should return failed result") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .failure)

                guard case .failure = projectResult else {
                    fail("Expected error, got \(projectResult)")
                    return
                }

                expect(try? projectResult.get()).to(beNil())
            }
        }

        describe("invalid project ID causing invalid API URL") {
            it("should fail with error") {
                var result: Result<Assets, ZeplinAPI.Error>?
                Prism(jwtToken: "dsadas").getAssets(for: .project(id: "|||")) { res in result = res }

                switch result {
                case .some(.failure(let error)):
                    expect(error.description.starts(with: "Failed constructing URL from path")).to(beTrue())
                default:
                    fail("Expected invalid project ID error, got \(String(describing: result))")
                }
            }
        }

        describe("invalid styleguide ID causing invalid API URL") {
            it("should fail with error") {
                var result: Result<Assets, ZeplinAPI.Error>?
                Prism(jwtToken: "dsadas").getAssets(for: .styleguide(id: "|||")) { res in result = res }

                switch result {
                case .some(.failure(let error)):
                    expect(error.description.starts(with: "Failed constructing URL from path")).to(beTrue())
                default:
                    fail("Expected invalid styleguide ID error, got \(String(describing: result))")
                }
            }
        }

        describe("description") {
            it("should not be empty") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successfulProject)
                let project = try! projectResult.get()

                expect(project.description).toNot(beEmpty())
            }
        }

        describe("owner description") {
            it("should return correct id for either owner") {
                let owners: [AssetOwner] = [
                    .project(id: "123"),
                    .styleguide(id: "321"),
                    .styleguide(id: "sg"),
                    .project(id: "pj")
                ]

                expect(owners.map(\.description)).to(equal(["Project 123",
                                                            "Styleguide 321",
                                                            "Styleguide sg",
                                                            "Project pj"]))
            }
        }

        describe("owner id") {
            it("should return correct id for either owner") {
                let owners: [AssetOwner] = [
                    .project(id: "123"),
                    .styleguide(id: "321"),
                    .styleguide(id: "sg"),
                    .project(id: "pj")
                ]

                expect(owners.map(\.id)).to(equal(["123", "321", "sg", "pj"]))
            }
        }
    }
}
