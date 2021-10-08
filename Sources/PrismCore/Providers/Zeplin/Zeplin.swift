//
//  File.swift
//  
//
//  Created by Shai Mishali on 02/10/2021.
//

import Foundation
import ProviderCore
import ZeplinSwift

/// Zeplin Asset Provider (http://zeplin.io)
public struct Zeplin: AssetProviding {
    let api: ZeplinSwift.ZeplinAPI

    public static var provider: AssetProvider { .zeplin }

    public init(api: ZeplinSwift.ZeplinAPI) {
        self.api = api
    }
}

public extension Zeplin {
    typealias Scope = ZeplinSwift.AssetOwner
}

extension Zeplin {
    /// Get text styles, colors and spacing tokens for a specified project
    /// or styleguide and pack them into a single `Assets` object.
    ///
    /// - Note:
    ///     Due to the nature of Zeplin's API, you can't get _all_ assets for
    ///     project or text style in a single call. You have to get assets separately
    ///     for each child styleguide of a project or owner styleguide.
    ///     Getting these styleguides also incurs an additional API call.
    ///
    ///     In essence, getting all colors and text styles for a project incurs:
    ///
    ///         ((number_of_linked_styleguides + 1) * 2) + 1 API Calls
    ///
    ///     e.g. for a Project with 2 linked styleguides, Prism performs 7 API calls
    ///
    /// - parameter owner: Assets owner, e.g. a project or styleguide
    /// - parameter completion: A completion handler which can result in a successful `Assets`
    ///                         object, or a `ZeplinAPI.Error` error
    public func getAssets(
        for scope: Scope,
        completion: @escaping (Result<Assets, ZeplinAPI.Error>) throws -> Void
    ) throws {
        let group = DispatchGroup()
        var colors = [ZeplinSwift.Color]()
        var textStyles = [ZeplinSwift.TextStyle]()
        var spacings = [ZeplinSwift.Spacing]()
        var errors = [ZeplinAPI.Error]()
        let projectId: String? = {
            guard case .project(let id) = scope else { return nil }
            return id
        }()

        // Wait for styleguide IDs we wish to query
        let (styleguideIDs, styleguideErrors) = getStyleguideIDs(for: scope)

        errors.append(contentsOf: styleguideErrors)

        // Get text styles, colors and spacing separately
        // for each styleguide
        for styleguideID in styleguideIDs {
            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getStyleguideColors(for: styleguideID,
                                            linkedProject: projectId,
                                            page: page,
                                            completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &colors, errors: &errors)
                    group.leave()
                }
            )

            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getStyleguideTextStyles(for: styleguideID,
                                                linkedProject: projectId,
                                                page: page,
                                                completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &textStyles, errors: &errors)
                    group.leave()
                }
            )

            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getStyleguideSpacings(for: styleguideID,
                                              linkedProject: projectId,
                                              page: page,
                                              completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &spacings, errors: &errors)
                    group.leave()
                }
            )
        }

        // If the asset owner is a project, get that project's colors,
        // text styles and spacing tokens as well
        if let projectId = projectId {
            // Get project colors
            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getProjectColors(for: projectId, page: page, completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &colors, errors: &errors)
                    group.leave()
                }
            )

            // Get project text styles
            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getProjectTextStyles(for: projectId, page: page, completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &textStyles, errors: &errors)
                    group.leave()
                }
            )

            // Get project spacing
            group.enter()
            api.getPagedItems(
                work: { page, api, completion in
                    api.getProjectSpacings(for: projectId, page: page, completion: completion)
                },
                completion: { result in
                    result.appendValuesOrErrors(values: &spacings, errors: &errors)
                    group.leave()
                }
            )
        }

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        group.wait()

        /// Fail if any asset identity is duplicated
        let duplicateColors = colors.map(\.identity.name).duplicates().sorted(by: <)
        let duplicateTextStyles = textStyles.map(\.identity.name).duplicates().sorted(by: <)
        let duplicateSpacings = spacings.map(\.identity.name).duplicates().sorted(by: <)

        if !duplicateSpacings.isEmpty {
            errors.append(.duplicateColors(identities: duplicateColors))
        }

        if !duplicateTextStyles.isEmpty {
            errors.append(.duplicateTextStyles(identities: duplicateTextStyles))
        }

        if !duplicateSpacings.isEmpty {
            errors.append(.duplicateSpacings(identities: duplicateSpacings))
        }

        if !errors.isEmpty {
            try completion(.failure(.compoundError(errors: errors)))
        } else {
            let allColors = colors.map { ProviderCore.Color(zeplinColor: $0) }
            let allTextStyles = textStyles.map { ProviderCore.TextStyle(zeplinTextStyle: $0) }
            let allSpacings = spacings.map { ProviderCore.Spacing(zeplinSpacing: $0) }
            try completion(.success(
                Assets(
                    colors: allColors.sorted { $0.name < $1.name },
                    textStyles: allTextStyles.sorted { $0.name < $1.name },
                    spacing: allSpacings.sorted(by: { $0.value < $1.value })
                )
            ))
        }
    }
}

// MARK: - Private Helpers
private extension Zeplin {
    /// Get all styleguide IDs for a provided asset owner (e.g. project or styleguide)
    ///
    /// - note: This is a blocking, synchronous, method.
    ///
    /// - returns: Array of styleguide IDs and arraay of errors, if any occurred.
    private func getStyleguideIDs(for owner: AssetOwner) -> (ids: [Styleguide.ID], errors: [ZeplinAPI.Error]) {
        let group = DispatchGroup()
        var styleguideIDs = [Styleguide.ID]()
        var errors = [ZeplinAPI.Error]()

        // Get all linked project or styleguide styleguides
        group.enter()
        api.getStyleguides(for: owner) { result in
            defer { group.leave() }

            switch result {
            case .success(let styleguides):
                styleguideIDs = styleguides.map(\.id)
            case .failure(let error):
                errors.append(error)
            }
        }

        group.wait()
        return (styleguideIDs, errors)
    }
}

private extension ZeplinAPI {
    /// Perform as many needed requests to `work` to fetch all
    /// paged results of the required reesource
    func getPagedItems<Output>(currentPage: Int = 1,
                               work: @escaping (Int, ZeplinAPI, @escaping (Result<[Output], Error>) -> Void) -> Void,
                               currentValues: [Output] = [],
                               completion: @escaping (Result<[Output], Error>) -> Void) {
        work(currentPage, self) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let items):
                if items.count == ZeplinAPI.itemsPerPage {
                    self.getPagedItems(currentPage: currentPage + 1,
                                       work: work,
                                       currentValues: currentValues + items,
                                       completion: completion)
                } else {
                    completion(.success(currentValues + items))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
