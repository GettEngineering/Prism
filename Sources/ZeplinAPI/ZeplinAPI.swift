//
//  ZeplinAPI.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation

// Zeplin's API Interface
public class ZeplinAPI {
    private let jwtToken: String
    static let basePath = "https://api.zeplin.dev/v1/"
    
    /// Instantiate an instance of the Zeplin API with a
    /// provided JWT token
    public init(jwtToken: String) {
        self.jwtToken = jwtToken
    }

    /// Fetch all colors associated with a specific Zeplin Project ID
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch colors for
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Color`s, or a `ZeplinAPI.Error` error
    public func getColors(for projectId: Project.ID, completion: @escaping (Result<[Project.Color], Error>) -> Void) {
        request(model: [Project.Color].self, from: "projects/\(projectId)/colors", completion: completion)
    }
    
    /// Fetch all text styles associated with a specific Zeplin Project ID
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch text styles for
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `TextStyle`s, or a `ZeplinAPI.Error` error
    public func getTextStyles(for projectId: Project.ID, completion: @escaping (Result<[Project.TextStyle], Error>) -> Void) {
        request(model: [Project.TextStyle].self, from: "projects/\(projectId)/text_styles", completion: completion)
    }
    
    /// Fetch all projects associated with the user whose token is used
    /// for the APIs
    ///
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Project`s, or a `ZeplinAPI.Error` error
    public func getProjects(completion: @escaping (Result<[Project], Error>) -> Void) {
        request(model: [Project].self, from: "projects", completion: completion)
    }
}

// MARK: - Private Helpers
private extension ZeplinAPI {
    func request<Model: Decodable>(model: Model.Type,
                                   from path: String,
                                   completion: @escaping (Result<Model, Error>) -> Void) {
        let fullPath = ZeplinAPI.basePath + path
        
        guard let apiURL = URL(string: fullPath) else {
            completion(.failure(Error.invalidRequestURL(path: fullPath)))
            return
        }

        let request = URLRequest(url: apiURL, jwtToken: jwtToken)
        
        URLSession.shared
            .dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse,
                   let data = data,
                   !(200...299 ~= response.statusCode) {
                    do {
                        let error = try APIError.decode(from: data)
                        completion(.failure(.apiError(message: "\(error.detail) (\(error.message))")))
                    } catch {
                        completion(.failure(Error.unknownAPIError(statusCode: response.statusCode)))
                    }
                    return
                }
                
                do {
                    if let data = data {
                        try completion(.success(Model.decode(from: data,
                                                             keyDecodingStrategy: .convertFromSnakeCase)))
                    }
                } catch {
                    completion(.failure(Error.decodingFailed(type: Model.self)))
                }
            }
            .resume()
    }
}

private extension URLRequest {
    init(url: URL, jwtToken: String) {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        self = request
    }
}

// MARK: - Zeplin API Errors
extension ZeplinAPI {
    public enum Error: Swift.Error, CustomStringConvertible {
        case invalidRequestURL(path: String)
        case decodingFailed(type: Decodable.Type)
        case unknownAPIError(statusCode: Int)
        case apiError(message: String)

        public var description: String {
            switch self {
            case .invalidRequestURL(let path):
                return "Failed constructing URL from path '\(path)'"
            case .decodingFailed(let type):
                return "Failed decoding \(type)"
            case .unknownAPIError(let statusCode):
                return "An unknown API error occured: HTTP \(statusCode)"
            case .apiError(let message):
                return "Zeplin API Failure: \(message)"
            }
        }
    }
    
    // Private struct used to parse Zeplin's API Error Model
    private struct APIError: Codable {
        let detail: String
        let message: String
    }
}
