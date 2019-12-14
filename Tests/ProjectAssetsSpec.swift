//
//  ProjectSpec.swift
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

class ProjectAssetsSpec: QuickSpec {
    override func spec() {
        describe("project snapshot") {
            it("is valid") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()

                assertSnapshot(matching: "\(project.debugDescription)",
                               as: .lines,
                               named: "project snapshot is valid")
            }
        }

        describe("project decoding from JSON") {
            context("successful") {
                it("should suceed and return valid Project") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    expect(project.id) == "12345"
                    expect(project.colors.map { $0.argbValue }.joined(separator: ", ")) == "#ccdf6369, #ff62b6df"
                    expect(project.textStyles.map { $0.name }.joined(separator: ", ")) == "Large Heading, Body"

                    let encoded = try! project.encode()
                    let decoded = try! ProjectAssets.decode(from: encoded)

                    expect(project) == decoded
                }
            }

            context("failed") {
                it("should fail decoding") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .faultyJSON)

                    guard case .failure = projectResult else {
                        fail("Expected error, got \(projectResult)")
                        return
                    }

                    expect(try? projectResult.get()).to(beNil())
                }
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
                var result: Result<ProjectAssets, ZeplinAPI.Error>?
                Prism(jwtToken: "dsadas").getProjectAssets(for: "|||") { res in result = res }

                switch result {
                case .some(.failure(let error)):
                    guard case .invalidRequestURL = error else {
                        fail("Expected error .invalidRequestURL, got \(error)")
                        return
                    }
                    expect(error.description.starts(with: "Failed constructing URL from path")).to(beTrue())
                default:
                    fail("Expected invalid project ID error, got \(String(describing: result))")
                }
            }
        }

        describe("description") {
            it("should not be empty") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()

                expect(project.description).toNot(beEmpty())
            }
        }
    }
}
