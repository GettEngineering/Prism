//
//  Prism.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ZeplinAPI

/// Prism is the main class responsible for fetching the raw
/// API data from Zeplin and return
public class Prism {
    private let api: ZeplinAPI

    public init(jwtToken: String) {
        self.api = ZeplinAPI(jwtToken: jwtToken)
    }
    
    /// Get the project's assets, e.g. colors and text styles
    /// and pack them into a single `ProjectAssets` object
    ///
    /// - parameter projectId: A Zeplin project ID
    /// - parameter completion: A completion handler which can result in a successful `ProjectAssets`
    ///                         object, or a `ZeplinAPI.Error` error
    public func getProjectAssets(for projectId: Project.ID,
                                 completion: @escaping (Result<ProjectAssets, ZeplinAPI.Error>) -> Void) {
        let group = DispatchGroup()
        var colors = [Project.Color]()
        var textStyles = [Project.TextStyle]()
        var outError: ZeplinAPI.Error?
        
        group.enter()
        api.getColors(for: projectId) { result in
            defer { group.leave() }
            switch result {
            case .success(let color):
                colors = color
            case .failure(let error):
                outError = error
            }
        }
        
        group.enter()
        api.getTextStyles(for: projectId) { result in
            defer { group.leave() }
            switch result {
            case .success(let styles):
                textStyles = styles
            case .failure(let error):
                outError = error
            }
        }

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        group.wait()
        
        if let err = outError {
            completion(.failure(err))
        } else {
            completion(.success(ProjectAssets(id: projectId, colors: colors, textStyles: textStyles)))
        }
    }
}
