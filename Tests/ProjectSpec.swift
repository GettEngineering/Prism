//
//  ProjectSpec.swift
//  Prism
//
//  Created by Shai Mishali on 22/05/2019.
//

import Foundation
import Quick
import Nimble
@testable import PrismCore

class ProjectSpec: QuickSpec {
    override func spec() {
        describe("project decoding from JSON") {
            context("successful") {
                it("should suceed and return valid Project") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    expect(project.id) == "5xxad123dsadasxsaxsa"
                    expect(project.name) == "Fake Project Test"
                    expect(project.colors.map { $0.argbValue }.joined(separator: ", ")) == "#ccdf6369, #ff62b6df"
                    expect(project.textStyles.map { $0.name }.joined(separator: ", ")) == "Large Heading, Body"

                    let encoded = try! project.encode()
                    let decoded = try! Prism.Project.decode(from: encoded)

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
                var result: Prism.ProjectResult?
                Prism(jwtToken: "dsadas").getProject(id: "|||") { res in result = res }

                switch result {
                case .some(.failure(let error as Prism.Error)):
                    expect(error) == Prism.Error.invalidProjectId
                default:
                    fail("Expected invalid project ID error, got \(String(describing: result))")
                }
            }
        }

        describe("colorIdentity(for:)") {
            context("no color match") {
                it("should return nil") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    let nonExistingColor = Prism.Project.RawColor(r: 255, g: 245, b: 200, a: 1.0)

                    expect(project.colorIdentity(for: nonExistingColor)).to(beNil())
                }
            }

            context("color matches") {
                it("should return correct color with identity") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()

                    let existingColors = [
                        Prism.Project.RawColor(r: 223, g: 99, b: 105, a: 0.79999995),
                        Prism.Project.RawColor(r: 98, g: 182, b: 223, a: 1.0)
                    ]

                    let matchingColors = existingColors.compactMap { project.colorIdentity(for: $0) }

                    expect(matchingColors.count) == 2
                    expect(matchingColors[0].iOS) == "clearReddish"
                    expect(matchingColors[1].iOS) == "blueSky"
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
