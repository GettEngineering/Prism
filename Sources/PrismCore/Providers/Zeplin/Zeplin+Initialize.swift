//
//  Zeplin+Initialize.swift
//  Prism
//
//  Created by Shai Mishali on 12/10/2021.
//  Copyright © 2021 Gett. All rights reserved.
//

import Foundation
import ZeplinSwift
import ProviderCore

public extension Zeplin {
    static func initialize() throws -> Configuration {
        guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] else {
            throw Error.missingToken
        }

        print("""

                                       ::::::::::::::::::
                                  :-::::::::::::::::::::::::.
                               ::::-::::::::::::::::::::::::::
                            :--::::-::::::::::::::::::::::::::-
                         :::::--:::-:::::::::::::::::::::-------
                       ::::::::--::=::::::::::::::::-----------=
                     :::::::::::--:=:::::::::::---------------=
                    :::::::::::::--=::::::------------------==
                 .::::::::::::::::-=::------Zeplin--------===
             ----::::::::::::::::--==-------------------====
           ------:::::::::::--------==---------------=====
             ----::::::-------------=-=-----------======
              ---:------------------=---=-----========
               :::------------------=---===========
               ::::-=------------==============
               :::::--====================
               :::::.        Zeplin ➡ Prism = 🌈🎨
               ::.

        """)

        let assetType: AssetType = UserInput(message: "🎨 Use a project or style guide?").request()
        let api = API(jwtToken: jwtToken)
        let dispatchGroup = DispatchGroup()

        switch assetType {
        case .project:
            return pickProject(api: api, dispatchGroup: dispatchGroup)
        case .styleguide:
            return pickStyleguide(api: api, dispatchGroup: dispatchGroup)
        }
    }
}

private extension Zeplin {
    /// Let the user pick a single Zeplin project for Prism
    /// to generate your design code from
    ///
    /// - parameter api: An instance of a Zeplin API
    /// - parameter config: An `inout` array representing prism options
    /// - parameter disaptchGroup: A `DispatchGroup` for the API requests
    static func pickProject(api: API, dispatchGroup: DispatchGroup) -> Configuration {
        // Let user select a project
        print("⏳ Getting your projects ...")

        dispatchGroup.enter()
        var projects = [Project]()

        api.getProjects { result in
            do {
                defer { dispatchGroup.leave() }
                projects = try result.get().filter { $0.status == .active }
            } catch let err {
                terminate(with: "Failed fetching projects: \(err)")
            }
        }

        dispatchGroup.wait()

        guard !projects.isEmpty else {
            terminate(with: "❌ No projects found for your user!")
        }

        print("🔎 Found \(projects.count) projects:")

        for (idx, project) in projects.enumerated() {
            print("  \(idx+1)) \(project.platform.emoji) \(project.name)")
        }

        let projectNumber = UserInput(message: "Pick a project").request(range: 1...projects.count)
        let project = projects[projectNumber - 1]

        return .init(projectId: project.id, styleguideId: nil)
    }

    /// Let the user pick a single Zeplin style guide for Prism
    /// to generate your design code from
    ///
    /// - parameter api: An instance of a Zeplin API
    /// - parameter config: An `inout` array representing prism options
    /// - parameter disaptchGroup: A `DispatchGroup` for the API requests
    static func pickStyleguide(api: API,
                               dispatchGroup: DispatchGroup) -> Configuration {
        // Let user select a project
        print("⏳ Getting your styleguides ...")

        dispatchGroup.enter()
        var styleguides = [Styleguide]()

        api.getStyleguides { result in
            do {
                defer { dispatchGroup.leave() }
                styleguides = try result.get().filter { $0.status == .active }
            } catch let err {
                terminate(with: "Failed fetching styleguides: \(err)")
            }
        }

        dispatchGroup.wait()

        guard !styleguides.isEmpty else {
            terminate(with: "❌ No styleguides found for your user!")
        }

        print("🔎 Found \(styleguides.count) styleguides:")

        for (idx, project) in styleguides.enumerated() {
            print("  \(idx+1)) \(project.platform.emoji) \(project.name)")
        }

        let projectNumber = UserInput(message: "Pick a stylegude").request(range: 1...styleguides.count)
        let styleguide = styleguides[projectNumber - 1]

        return .init(projectId: nil, styleguideId: styleguide.id)
    }

    private enum AssetType: InputOption, CaseIterable {
        case project
        case styleguide

        var aliases: [String] {
            switch self {
            case .project:
                return ["project", "p"]
            case .styleguide:
                return ["styleguide", "s"]
            }
        }
    }
}
