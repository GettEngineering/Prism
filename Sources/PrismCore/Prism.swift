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
    /// - Note:
    ///     Due to the nature of Zeplin's API, you can't get _all_ colors and
    ///     text styles for a project in a single call. You have to get colors
    ///     and text styles separately for each styleguide linked to a project.
    ///     Getting these styleguides also incurs an additional API call.
    ///
    ///     In essence, getting all colors and text styles for a project incurs:
    ///
    ///         ((number_of_linked_styleguides + 1) * 2) + 1 API Calls
    ///
    ///     e.g. for a Project with 2 linkted styleguides, Prism performs 7 API calls
    ///
    /// - parameter projectId: A Zeplin project ID
    /// - parameter completion: A completion handler which can result in a successful `ProjectAssets`
    ///                         object, or a `ZeplinAPI.Error` error
    public func getProjectAssets(for projectId: Project.ID,
                                 completion: @escaping (Result<ProjectAssets, ZeplinAPI.Error>) -> Void) {
        let group = DispatchGroup()
        var colors = [Color]()
        var textStyles = [TextStyle]()
        var errors = [ZeplinAPI.Error]()
        
        /// Get linked style guides and their colors and
        /// text styles for the project
        group.enter()
        api.getStyleguides(for: projectId) { [weak api] result in
            defer { group.leave() }
            guard let api = api else { return }

            switch result {
            case .success(let styleguides):
                // Get text styles and colors separately
                // for each styleguide
                for styleguide in styleguides {
                    group.enter()
                    api.getStyleguideColors(for: styleguide.id) { result in
                        defer { group.leave() }
                        result.appendValuesOrErrors(values: &colors, errors: &errors)
                    }
                    
                    group.enter()
                    api.getStyleguideTextStyles(for: styleguide.id) { result in
                        defer { group.leave() }
                        result.appendValuesOrErrors(values: &textStyles, errors: &errors)
                    }
                }
            case .failure(let error):
                errors.append(error)
            }
        }
        
        // Get project colors
        group.enter()
        api.getProjectColors(for: projectId) { result in
            defer { group.leave() }
            result.appendValuesOrErrors(values: &colors, errors: &errors)
        }
        
        // Get project text styles
        group.enter()
        api.getProjectTextStyles(for: projectId) { result in
            defer { group.leave() }
            result.appendValuesOrErrors(values: &textStyles, errors: &errors)
        }

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        group.wait()
        if !errors.isEmpty {
            completion(.failure(.compoundError(errors: errors)))
        } else {
            completion(.success(ProjectAssets(id: projectId,
                                              colors: colors.sorted { $0.name < $1.name },
                                              textStyles: textStyles.sorted { $0.name < $1.name })))
        }
    }
}

// MARK: - Private Helpers
private extension Result {
    /// On a successful response, append the results into the provided results array pointer.
    /// On a failed response, append the error into the provided errors array pointer.
    ///
    /// - parameter values: Results array pointer
    /// - parameter errors: Errors array pointer
    func appendValuesOrErrors<Output>(values: inout [Output], errors: inout [Failure]) {
        switch self {
        case .success(let result):
            guard let result = result as? [Output] else { return }
            values.append(contentsOf: result)
        case .failure(let error):
            errors.append(error)
        }
    }
}
