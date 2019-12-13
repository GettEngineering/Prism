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
    
    private func request<Model: Decodable>(model: Model.Type,
                                           from path: String,
                                           completion: @escaping (Result<Model, Swift.Error>) -> Void) {
        guard let apiURL = URL(string: path) else {
            completion(.failure(Error.invalidProjectId))
            return
        }

        var request = URLRequest(url: apiURL)
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: Header.token.rawValue)
        
        URLSession.shared
            .dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse,
                   !(200...299 ~= response.statusCode) {
                    do {
                        let error = try APIError.decode(from: data ?? Data())
                        completion(.failure(error))
                    } catch {
                        completion(.failure(Error.unknownAPIError(statusCode: response.statusCode)))
                    }
                    return
                }
                
                do {
                    try completion(.success(Model.decode(from: data ?? Data(), keyDecodingStrategy: .convertFromSnakeCase)))
                } catch {
                    completion(.failure(Error.decodingFailed(type: Model.self)))
                }
            }
            .resume()
    }

    public func getProject(id: String,
                           completion: @escaping (ProjectResult) -> Void) {
        let group = DispatchGroup()
        var colors = [Project.Color]()
        var textStyles = [Project.TextStyle]()
        
        group.enter()
        request(model: [Project.Color].self,
                from: "https://api.zeplin.dev/v1/projects/\(id)/colors") { result in
            defer { group.leave() }
            switch result {
            case .success(let color):
                colors = color
            case .failure(let error):
                completion(.failure(error))
            }
        }

        group.enter()
        request(model: [Project.TextStyle].self,
                from: "https://api.zeplin.dev/v1/projects/\(id)/text_styles") { result in
            defer { group.leave() }
            switch result {
            case .success(let styles):
                textStyles = styles
            case .failure(let error):
                completion(.failure(error))
            }
        }

        /// It's required to wait and block here when running in CLI.
        /// Otherwise, Prism terminates without waiting for the result to
        /// come back.
        group.wait()
        completion(.success(Project(id: id, colors: colors, textStyles: textStyles)))
    }
}

private extension PrismAPI {
    enum Header: String {
        case token = "Authorization"
    }
}

extension PrismAPI {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidProjectId
        case requestFailed(path: String, message: String)
        case decodingFailed(type: Decodable.Type)
        case unknownAPIError(statusCode: Int)

        var description: String {
            switch self {
            case .invalidProjectId:
                return "The provided project ID can't be used to construct a API URL"
            case let .requestFailed(path, message):
                return "Failed requesting \(path): \(message)"
            case .decodingFailed(let type):
                return "Failed decoding \(type)"
            case .unknownAPIError(let statusCode):
                return "An unknown API error occured: HTTP \(statusCode)"
            }
        }
    }
    
    struct APIError: Codable, CustomStringConvertible, Swift.Error {
        let detail: String
        let message: String
        
        var description: String {
            return "API Error: \(detail) (\(message))"
        }
    }
}
