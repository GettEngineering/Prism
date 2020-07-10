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

        describe("description") {
            it("should not be empty") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()

                expect(project.description).toNot(beEmpty())
            }
        }
    }
}
