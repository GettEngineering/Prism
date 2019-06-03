//
//  Prism.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

/// PrismAPI is the main class responsible for fetching the raw
/// API data from Zeplin and decode it into a Prism `Project`.
public class PrismAPI {
    public typealias ProjectResult = Result<Project, Swift.Error>
    private let jwtToken: String

    public init(jwtToken: String) {
        self.jwtToken = jwtToken
    }

    public func getProject(id: String,
                           completion: @escaping (ProjectResult) -> Void) {
        guard let apiURL = URL(string: "https://api.zeplin.io/v2/projects/\(id)") else {
            completion(.failure(Error.invalidProjectId))
            return
        }

        var request = URLRequest(url: apiURL)
        request.addValue(jwtToken, forHTTPHeaderField: Header.token.rawValue)

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        let wait = WaitForResult<ProjectResult> { done in
            URLSession.shared
                .dataTask(with: request) { data, _, error in
                    let result: ProjectResult
                    defer { done(result) }

                    if let error = error {
                        result = .failure(error)
                        return
                    }

                    do {
                        result = .success(try Project.decode(from: data ?? Data()))
                    } catch let err {
                        result = .failure(err)
                    }
                }
                .resume()
        }

        completion(wait.result)
    }
}

private extension PrismAPI {
    enum Header: String {
        case token = "Zeplin-Token"
    }
}

extension PrismAPI {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidProjectId

        var description: String {
            return "The provided project ID can't be used to construct a API URL"
        }
    }
}
