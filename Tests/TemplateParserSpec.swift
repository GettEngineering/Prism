//
//  TemplateParserSpec.swift
//  Prism
//
//  Created by Shai Mishali on 30/05/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SnapshotTesting
@testable import PrismCore
@testable import ZeplinAPI

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
                    {{%color.identity%}}, {{%color.identity.camelcase%}}, {{%color.identity.snakecase%}} = {{%color.r%}}, {{%color.g%}}, {{%color.b%}}, {{%color.a%}}, {{%color.argb%}}, {{%color.ARGB%}}, {{%color.rgb%}}, {{%color.RGB%}}
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
                    {{%textStyle.identity%}}, {{%textStyle.identity.camelcase%}}, {{%textStyle.identity.snakecase%}} = {{%textStyle.fontName%}}, {{%textStyle.fontSize%}}, {{%textStyle.color.identity%}},  {{%textStyle.color.identity.camelcase%}}, {{%textStyle.color.identity.snakecase%}}, {{%textStyle.color.rgb%}}, {{%textStyle.color.argb%}}, {{%textStyle.color.r%}}, {{%textStyle.color.g%}}, {{%textStyle.color.b%}}, {{%textStyle.color.a%}}
                    {{% END textStyle %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Text Styles Loop should provide valid output")
            }
        }
        
        describe("Text Style without color identity") {
            it("should throw error when accessed") {
                let projectResult = try! Prism(jwtToken: "fake").mock(type: .successful).get()
                let modifiedResult = ProjectAssets(id: projectResult.id,
                                                   colors: [],
                                                   textStyles: Array(projectResult.textStyles.prefix(1)))
                
                let parser = TemplateParser(project: modifiedResult)
                expect {
                    try parser.parse(template: """
                    {{% FOR textStyle %}}
                    Bad color identity: {{%textStyle.color.identity%}}
                    {{% END textStyle %}}
                    """)
                }.to(throwError(TemplateParser.Error.missingColorForTextStyle(modifiedResult.textStyles[0])))
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

        describe("Errors") {
            context("localized description") {
                it("should have valid descriptions") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    
                    let errors: [TemplateParser.Error] = [.openLoop(identifier: "color"),
                                                          .unknownLoop(identifier: "fake"),
                                                          .unknownToken(token: "fake"),
                                                          .missingColorForTextStyle(project.textStyles[1]),
                                                          .prohibitedIdentities(identities: "fake1, fake2")]

                    let descriptions = errors.map { "\($0)" }
                    let expectedDescriptions = [
                        "Detected FOR loop 'color' with no closing END",
                        "Illegal FOR loop identifier 'fake'",
                        "Illegal token in template 'fake'",
                        "Text Style Base Subhead has a color RGBA(166, 14, 14, 1.0), but it has no matching color identity",
                        "Prohibited identities 'fake1, fake2' can't be used"
                    ]

                    expect(descriptions) == expectedDescriptions
                }
            }
        }

        describe("Token") {
            context("unknown token") {
                it("should return nil") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    expect { try TemplateParser.Token(rawColorToken: UUID().uuidString,
                                                      color: project.colors[0]) }.to(throwError())
                    expect { try TemplateParser.Token(rawTextStyleToken: UUID().uuidString,
                                                      textStyle: project.textStyles[0],
                                                      colors: project.colors) }.to(throwError())
                }
            }

            context("unknown color identity") {
                it("should return nil token") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    expect { try TemplateParser.Token(rawTextStyleToken: "textStyle.color.identity.camelcase",
                                                      textStyle: project.textStyles[0],
                                                      colors: []) }.to(throwError(TemplateParser.Error.missingColorForTextStyle(project.textStyles[0])))
                    expect { try TemplateParser.Token(rawTextStyleToken: "textStyle.color.identity.snakecase",
                                                      textStyle: project.textStyles[0],
                                                      colors: []) }.to(throwError(TemplateParser.Error.missingColorForTextStyle(project.textStyles[0])))
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
                {{%textStyle.identity.camelcase|lowercase%}}
                {{%textStyle.identity.snakecase|uppercase%}}
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
                it("should throw error") {
                    let fake = UUID().uuidString
                    expect { try TemplateParser.Transformation(rawValue: fake) }
                        .to(throwError(TemplateParser.Error.unknownTransformation(fake)))
                }
            }
            
            context("invalid transformation format") {
                it("should throw error") {
                    let fake = "hey("
                    expect { try TemplateParser.Transformation(rawValue: fake) }
                        .to(throwError(TemplateParser.Error.unknownTransformation(fake)))
                }
            }
        }

        describe("Prohibited Identifiers") {
            let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
            let project = try! projectResult.get()

            context("camel cased") {
                it("should throw an error") {
                    let configuration = PrismCore.Configuration(projectId: "12345",
                                                                templatesPath: "./",
                                                                outputPath: "./",
                                                                reservedColors: ["blueSky", "clearReddish"],
                                                                reservedTextStyles: ["body", "largeHeading"])
                    let parser = TemplateParser(project: project, configuration: configuration)

                    expect { try parser.parse(template: "") }
                        .to(throwError(TemplateParser.Error.prohibitedIdentities(identities: "blueSky, clearReddish, body, largeHeading")))
                }
            }

            context("snake cased") {
                it("should throw an error") {
                    let configuration = PrismCore.Configuration(projectId: "12345",
                                                                templatesPath: "./",
                                                                outputPath: "./",
                                                                reservedColors: ["blue_sky", "clear_reddish"],
                                                                reservedTextStyles: ["body", "large_heading"])
                    let parser = TemplateParser(project: project, configuration: configuration)

                    expect { try parser.parse(template: "") }
                        .to(throwError(TemplateParser.Error.prohibitedIdentities(identities: "blue_sky, clear_reddish, body, large_heading")))
                }
            }
        }
    }
}
