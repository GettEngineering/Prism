//
//  TemplateParserSpec.swift
//  Prism
//
//  Created by Shai Mishali on 30/05/2019.
//

import Foundation
import Quick
import Nimble
import SnapshotTesting
@testable import PrismCore

class TemplateParserSpec: QuickSpec {
    override func spec() {
        describe("Color Loop") {
            it("should produce valid output") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism, Gett's Design System code generator.
                /// https://github.com/GettEngineering/Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR color %}}
                    {{%color.identity.iOS%}}, {{%color.identity.android%}} = {{%color.r%}}, {{%color.g%}}, {{%color.b%}}, {{%color.a%}}
                    {{% END color %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Color Loop should provide valid output")
            }
        }

        describe("Text Styles Loop") {
            it("should produce valid output") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism, Gett's Design System code generator.
                /// https://github.com/GettEngineering/Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR textStyle %}}
                    {{%textStyle.identity.iOS%}}, {{%textStyle.identity.android%}} = {{%textStyle.fontName%}}, {{%textStyle.color.identity.iOS%}}, {{%textStyle.color.identity.android%}}, {{%textStyle.fontSize%}}
                    {{% END textStyle %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Text Styles Loop should provide valid output")
            }
        }

        describe("Open loop with no closing") {
            it("should throw error") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism, Gett's Design System code generator.
                /// https://github.com/GettEngineering/Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR color %}}
                    xyz
                }
                """

                expect { try parser.parse(template: template) }
                    .to(throwError(TemplateParser.Error.openLoop(identifier: "color")))
            }
        }

        describe("Unknown Loop") {
            it("should throw error") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism, Gett's Design System code generator.
                /// https://github.com/GettEngineering/Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR whatever %}}
                    xyz
                    {{% END whatever %}}
                }
                """

                expect { try parser.parse(template: template) }
                    .to(throwError(TemplateParser.Error.unknownLoop(identifier: "whatever")))
            }
        }

        describe("Token") {
            context("unknown token") {
                it("should return nil") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    expect(TemplateParser.Token(rawToken: UUID().uuidString,
                                                color: project.colors[0])).to(beNil())
                    expect(TemplateParser.Token(rawToken: UUID().uuidString,
                                                textStyle: project.textStyles[0],
                                                colors: project.colors)).to(beNil())
                }
            }

            context("unknown color identity") {
                it("should return nil token") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    expect(TemplateParser.Token(rawToken: "textStyle.color.identity.iOS",
                                                textStyle: project.textStyles[0],
                                                colors: [])).to(beNil())
                    expect(TemplateParser.Token(rawToken: "textStyle.color.identity.android",
                                                textStyle: project.textStyles[0],
                                                colors: [])).to(beNil())
                }
            }
        }

        describe("Transormations") {
            it("should produce valid output") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                {{% FOR textStyle %}}
                {{%textStyle.identity.iOS|lowercase%}}
                {{%textStyle.identity.android|uppercase%}}
                {{%textStyle.fontName|uppercase%}}
                {{%textStyle.fontName|replace(-,_)%}}
                {{%textStyle.fontName|lowercase|replace(-,_)%}}
                ==============================================
                {{% END textStyle %}}
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Transformations should provide valid output")
            }

            context("unknown transformation") {
                it("should return nil") {
                    expect(TemplateParser.Transformation(rawValue: UUID().uuidString)).to(beNil())
                }
            }
        }
    }
}
