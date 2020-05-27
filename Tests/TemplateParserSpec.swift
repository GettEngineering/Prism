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
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR color %}}
                    {{%color.identity%}}, {{% IF color.isFirst %}}This is the first color, {{% ENDIF %}}{{% IF color.isLast %}}This is the last color, {{% ENDIF %}}{{%color.identity.camelcase%}}, {{%color.identity.snakecase%}} = {{%color.r%}}, {{%color.g%}}, {{%color.b%}}, {{%color.a%}}, {{%color.argb%}}, {{%color.ARGB%}}, {{%color.rgb%}}, {{%color.RGB%}}, {{% IF color.argb %}}inline conditionally getting the ARGB value {{%color.argb%}}, right?{{% ENDIF %}}
                    {{% END color %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Color Loop should provide valid output")
            }
        }

        describe("Single Color Loop") {
            it("should match both isFirst and isLast") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = ProjectAssets(id: "12345",
                                            colors: [try! projectResult.get().colors.first!],
                                            textStyles: [],
                                            spacing: [])
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR color %}}
                    {{% IF color.isFirst %}}This is the first color{{% ENDIF %}}
                    {{% IF color.isLast %}}This is the last color{{% ENDIF %}}
                    {{% END color %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Single Color Loop should match both isFirst and isLast")
            }
        }

        describe("Text Styles Loop") {
            it("should produce valid output") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR textStyle %}}
                    {{% IF textStyle.isFirst %}}This is the first text style{{% ENDIF %}}
                    {{% IF !textStyle.isFirst %}}This is NOT the first text style{{% ENDIF %}}
                    {{% IF textStyle.isLast %}}This is the last text style{{% ENDIF %}}
                    {{% IF !textStyle.isLast %}}This is NOT the last text style{{% ENDIF %}}
                    {{% IF textStyle.lineHeight %}}line height is {{%textStyle.lineHeight%}}, {{% ENDIF %}}{{%textStyle.identity%}}, {{%textStyle.identity.camelcase%}}, {{%textStyle.identity.snakecase%}}, {{%textStyle.identity.kebabcase%}}, {{%textstyle.identity.pascalcase%}} = {{%textStyle.fontName%}}, {{%textStyle.fontSize%}}, {{%textStyle.fontWeight%}}, {{%textStyle.fontStyle%}}, {{%textStyle.fontStretch%}}, {{%textStyle.color.identity%}}, {{%textStyle.color.identity.camelcase%}}, {{%textStyle.color.identity.snakecase%}}, {{%textStyle.color.identity.kebabcase%}}, {{%textStyle.color.identity.pascalcase%}}, {{% IF textStyle.letterSpacing %}}letter spacing is: {{%textStyle.letterSpacing%}}, {{% ENDIF %}}{{%textStyle.color.rgb%}}, {{%textStyle.color.argb%}}, {{%textStyle.color.r%}}, {{%textStyle.color.g%}}, {{%textStyle.color.b%}}, {{%textStyle.color.a%}}{{% IF textStyle.alignment %}}, alignment is {{%textStyle.alignment%}}{{% ENDIF %}}
                        {{% IF textStyle.alignment %}}
                        This is an attempt of an indented multi-line
                        block containing a text alignment, which is {{%textStyle.alignment%}}
                        and also capable of inlining another condition
                        like {{% IF textStyle.color.argb %}}getting the ARGB value {{%textStyle.color.argb%}}, right?{{% ENDIF %}}
                        {{% ENDIF %}}
                        {{% IF !textStyle.alignment %}}
                        The text style {{% textStyle.identity %}} has no alignment
                        {{% ENDIF %}}
                        We can also access optional stuff without an IF, which will result in an empty string like so: {{%textStyle.alignment%}}
                    {{% END textStyle %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Text Styles Loop should provide valid output")
            }
        }

        describe("Text Style Color Conditional") {
            it("should ignore color tokens") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let baseProject = try! projectResult.get()
                let noColorTextStyle = TextStyle(id: "42142141",
                                                 name: "Fake Style 2",
                                                 postscriptName: "fake-style2",
                                                 fontFamily: "fake2",
                                                 fontSize: 24,
                                                 fontWeight: 4,
                                                 fontStyle: "medium",
                                                 fontStretch: 1,
                                                 lineHeight: nil,
                                                 letterSpacing: nil,
                                                 textAlign: nil,
                                                 color: nil)
                let project = ProjectAssets(id: baseProject.id,
                                            colors: baseProject.colors,
                                            textStyles: baseProject.textStyles + [noColorTextStyle],
                                            spacing: baseProject.spacing)
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some Structure {
                {{% FOR textStyle %}}
                    {{% textStyle.identity %}}
                    {{% IF textStyle.color.identity %}}{{%textStyle.color.identity%}}{{% ENDIF %}}
                    {{% IF textStyle.color %}}{{%textStyle.color.identity%}}{{% ENDIF %}}
                    {{% IF textstyle.color %}}
                    {{% textStyle.color.identity.camelcase %}},
                        {{% textStyle.color.identity.snakecase %}}, {{% textStyle.color.identity.kebabcase %}}, {{% textStyle.color.identity.pascalcase %}}, {{% textStyle.color.rgb %}}, {{% textStyle.color.argb %}},
                               {{% textStyle.color.r %}}, {{% textStyle.color.g %}}, {{% textStyle.color.b %}}, {{% textStyle.color.a %}}
                    {{% ENDIF %}}
                ============
                {{% END textStyle %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Color conditional should skip missing colors")
            }
        }

        describe("Spacing Loop") {
            it("should produce valid output") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some SpacingSructure {
                    {{% FOR spacing %}}
                    {{%spacing.identity%}}, {{% spacing.identity.camelcase %}}, {{%spacing.identity.snakecase%}}, {{%spacing.identity.kebabcase%}}, {{%spacing.identity.pascalcase%}} = {{% spacing.value %}}{{% IF !spacing.isLast %}},{{% ENDIF %}}
                    {{% END spacing %}}
                }
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Spacing Loop should provide valid output")
            }
        }
        
        describe("Invalid tokens") {
            context("text style") {
                it("should throw an error") {
                    let projectResult = try! Prism(jwtToken: "fake").mock(type: .successful).get()
                    let parser = TemplateParser(project: projectResult)

                    expect {
                        try parser.parse(template: """
                        {{% FOR textStyle %}}
                        Bad token {{%textStyle.nonExistentToken%}}
                        {{% END textStyle %}}
                        """)
                    }.to(throwError(TemplateParser.Error.unknownToken(token: "textStyle.nonExistentToken")))
                }
            }
            
            context("colors") {
                it("should throw an error") {
                    let projectResult = try! Prism(jwtToken: "fake").mock(type: .successful).get()
                    let parser = TemplateParser(project: projectResult)

                    expect {
                        try parser.parse(template: """
                        {{% FOR color %}}
                        Bad token {{%color.nonExistentToken%}}
                        {{% END color %}}
                        """)
                    }.to(throwError(TemplateParser.Error.unknownToken(token: "color.nonExistentToken")))
                }
            }

            context("spacing") {
                it("should throw an error") {
                    let projectResult = try! Prism(jwtToken: "fake").mock(type: .successful).get()
                    let parser = TemplateParser(project: projectResult)

                    expect {
                        try parser.parse(template: """
                        {{% FOR spacing %}}
                        Bad token {{%spacing.nonExistentToken%}}
                        {{% END spacing %}}
                        """)
                    }.to(throwError(TemplateParser.Error.unknownToken(token: "spacing.nonExistentToken")))
                }
            }
        }
        
        describe("Text Style without color identity") {
            it("should throw error when accessed") {
                let projectResult = try! Prism(jwtToken: "fake").mock(type: .successful).get()
                let modifiedResult = ProjectAssets(id: projectResult.id,
                                                   colors: [],
                                                   textStyles: Array(projectResult.textStyles.prefix(1)),
                                                   spacing: [])
                
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

        describe("Text Style color accessed with no color") {
            it("should throw an error when accessed") {
                let assets = ProjectAssets(
                    id: "12345",
                    colors: [Color(name: "Fake", r: 255, g: 100, b: 100, a: 1.0)],
                    textStyles: [TextStyle(id: "12321312",
                                           name: "Fake Style",
                                           postscriptName: "fake-style",
                                           fontFamily: "fake",
                                           fontSize: 16,
                                           fontWeight: 2,
                                           fontStyle: "light",
                                           fontStretch: 0.75,
                                           lineHeight: nil,
                                           letterSpacing: nil,
                                           textAlign: nil,
                                           color: RawColor(r: 255, g: 100, b: 100, a: 1.0)),
                                 TextStyle(id: "42142141",
                                           name: "Fake Style 2",
                                           postscriptName: "fake-style2",
                                           fontFamily: "fake2",
                                           fontSize: 24,
                                           fontWeight: 4,
                                           fontStyle: "medium",
                                           fontStretch: 1.25,
                                           lineHeight: nil,
                                           letterSpacing: nil,
                                           textAlign: nil,
                                           color: nil)],
                    spacing: []
                )

                let parser = TemplateParser(project: assets)
                expect {
                    try parser.parse(template: """
                    {{% FOR textStyle %}}
                    Missing color identity: {{%textStyle.color.identity%}}
                    {{% END textStyle %}}
                    """)
                }.to(throwError(TemplateParser.Error.missingColorForTextStyle(assets.textStyles[1])))
            }
        }

        describe("Open loop with no closing") {
            it("should throw error") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

                fake line 1
                fake line 2

                Some Structure {
                    {{% FOR color %}}
                    xyz
                }
                """

                expect { try parser.parse(template: template) }
                    .to(throwError(TemplateParser.Error.openBlock(keyword: "FOR", identifier: "color")))
            }
        }

        describe("Unknown Loop") {
            it("should throw error") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                /// This file was generated using Prism

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
                    
                    let errors: [TemplateParser.Error] = [.openBlock(keyword: "FOR", identifier: "color"),
                                                          .openBlock(keyword: "IF", identifier: "textStyle.alignment"),
                                                          .unknownLoop(identifier: "fake"),
                                                          .unknownToken(token: "fake"),
                                                          .missingColorForTextStyle(project.textStyles[1]),
                                                          .prohibitedIdentities(identities: "fake1, fake2")]

                    let descriptions = errors.map { "\($0)" }
                    let expectedDescriptions = [
                        "Detected FOR block 'color' with no closing",
                        "Detected IF block 'textStyle.alignment' with no closing",
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
                    expect { try TemplateParser.Token(rawSpacingToken: UUID().uuidString,
                                                      spacing: project.spacing[0]) }.to(throwError())
                }
            }

            context("unknown color identity") {
                it("should return nil token") {
                    let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                    let project = try! projectResult.get()
                    for style in Project.AssetIdentity.Style.allCases.dropFirst() {
                        expect { try TemplateParser
                            .Token(rawTextStyleToken: "textStyle.color.identity.\(style.rawValue)",
                                   textStyle: project.textStyles[0],
                                   colors: [])
                            }
                        .to(throwError(TemplateParser.Error.missingColorForTextStyle(project.textStyles[0])))
                    }
                    
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
                No spaces on sides
                {{%textStyle.identity.camelcase|lowercase%}}
                {{%textStyle.identity.snakecase|uppercase%}}
                {{%textStyle.fontName|uppercase%}}
                {{%textStyle.fontName|replace(-,_)%}}
                {{%textStyle.fontName|replace("-","_")%}}
                {{%textStyle.fontName|lowercase|replace(-,"_")%}}

                Spaces on both sides
                {{% textStyle.identity.camelcase|lowercase %}}
                {{% textStyle.identity.snakecase|uppercase %}}
                {{% textStyle.fontName|uppercase %}}
                {{% textStyle.fontName|replace(-,_) %}}
                {{% textStyle.fontName|replace("-","_") %}}
                {{% textStyle.fontName|lowercase|replace(-,"_") %}}

                Space on left
                {{% textStyle.identity.camelcase|lowercase%}}
                {{% textStyle.identity.snakecase|uppercase%}}
                {{% textStyle.fontName|uppercase%}}
                {{% textStyle.fontName|replace(-,_)%}}
                {{% textStyle.fontName|replace("-","_")%}}
                {{% textStyle.fontName|lowercase|replace(-,"_")%}}

                Space on right
                {{%textStyle.identity.camelcase|lowercase %}}
                {{%textStyle.identity.snakecase|uppercase %}}
                {{%textStyle.fontName|uppercase %}}
                {{%textStyle.fontName|replace(-,_) %}}
                {{%textStyle.fontName|replace("-","_") %}}
                {{%textStyle.fontName|lowercase|replace(-,"_") %}}
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

        describe("Letter spacing") {
            it("should be rounded") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                {{% FOR textStyle %}}
                {{%textStyle.identity%}} {{%textStyle.letterSpacing%}}
                {{% END textStyle %}}
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Letter spacing should be rounded")
            }
        }

        describe("Line Height") {
            it("should be rounded") {
                let projectResult = Prism(jwtToken: "fake").mock(type: .successful)
                let project = try! projectResult.get()
                let parser = TemplateParser(project: project)

                let template = """
                {{% FOR textStyle %}}
                {{%textStyle.identity%}} {{%textStyle.lineHeight%}}
                {{% END textStyle %}}
                """

                assertSnapshot(matching: try! parser.parse(template: template),
                               as: .lines,
                               named: "Line height should be rounded")
            }
        }
    }
}
