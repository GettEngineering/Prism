//
//  Prism.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

public struct Prism {
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
                           completion: @escaping (Result<Project, Swift.Error>) -> Void) {
        var request = URLRequest(url: apiURL(for: id))
        request.addValue(jwtToken, forHTTPHeaderField: Header.token.rawValue)

        URLSession.shared
            .dataTask(with: request) { data, resp, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    completion(.success(try Prism.Project.decode(from: data ?? Data())))
                } catch let err {
                    completion(.failure(err))
                }
            }
            .resume()
    }
}

private extension Prism {
    enum Header: String {
        case token = "Zeplin-Token"
    }
}
