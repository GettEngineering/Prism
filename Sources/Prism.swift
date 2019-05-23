//
//  Prism.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public class Prism {
    public typealias ProjectResult = Result<Project, Swift.Error>
    private let jwtToken: String

    public init(jwtToken: String) {
        self.jwtToken = jwtToken
    }

    private func apiURL(for projectID: String) -> URL {
        guard let url = URL(string: "https://api.zeplin.io/v2/projects/\(projectID)") else {
            fatalError("Invalid API Path")
        }

        return url
    }

    public func getProject(id: String,
                           completion: @escaping (ProjectResult) -> Void) {
        var request = URLRequest(url: apiURL(for: id))
        request.addValue(jwtToken, forHTTPHeaderField: Header.token.rawValue)

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        let wait = WaitForResult<ProjectResult> { done in
            URLSession.shared
                .dataTask(with: request) { data, resp, error in
                    let result: ProjectResult
                    defer { done(result) }

                    if let error = error {
                        result = .failure(error)
                        return
                    }

                    do {
                        result = .success(try Prism.Project.decode(from: data ?? Data()))
                    } catch let err {
                        result = .failure(err)
                    }
                }
                .resume()
        }

        completion(wait.result)
    }
}

private extension Prism {
    enum Header: String {
        case token = "Zeplin-Token"
    }
}
