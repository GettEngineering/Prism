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
        let project = Prism(jwtToken: "fake").mock()

        describe("project decoding from JSON") {
            context("successful") {
                it("should suceed and return valid Project") {
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
                    let data = """
                        {
                            "some": "fake",
                            "json": "values"
                            "k": 2
                        }
                    """.data(using: .utf8)

                    let project = try? Prism.Project.decode(from: data ?? Data())
                    expect(project).to(beNil())
                }
            }
        }
    }
}
