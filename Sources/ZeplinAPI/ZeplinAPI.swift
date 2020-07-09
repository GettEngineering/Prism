//
//  ZeplinAPI.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Zeplin's API Interface
public class ZeplinAPI {
    private let jwtToken: String
    static let basePath = "https://api.zeplin.dev/v1/"

    /// Maximum number of items per page
    public static let itemsPerPage = 100
    
    /// Instantiate an instance of the Zeplin API with a
    /// provided JWT token
    public init(jwtToken: String) {
        self.jwtToken = jwtToken
    }
}

// MARK: - Project-Specific APIs
public extension ZeplinAPI {
    /// Fetch all projects associated with the user whose token is used
    /// for the APIs
    ///
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Project`s, or a `ZeplinAPI.Error` error
    func getProjects(page: Int = 1,
                     completion: @escaping (Result<[Project], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        request(model: [Project].self,
                from: "projects?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)",
                completion: completion)
    }
    
    /// Fetch all colors associated with a specific Zeplin Project
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch colors for
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Color`s, or a `ZeplinAPI.Error` error
    func getProjectColors(for projectId: Project.ID,
                          page: Int = 1,
                          completion: @escaping (Result<[Color], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        request(model: [Color].self,
                from: "projects/\(projectId)/colors?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)",
                completion: completion)
    }
    
    /// Fetch all text styles associated with a specific Zeplin Project
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch text styles for
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `TextStyle`s, or a `ZeplinAPI.Error` error
    func getProjectTextStyles(for projectId: Project.ID,
                              page: Int = 1,
                              completion: @escaping (Result<[TextStyle], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        request(model: [TextStyle].self,
                from: "projects/\(projectId)/text_styles?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)",
                completion: completion)
    }

    /// Fetch all spacing tokens associated with a specific Zeplin Project
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch spacing tokens for
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Spacing`s, or a `ZeplinAPI.Error` error
    func getProjectSpacings(for projectId: Project.ID,
                            page: Int = 1,
                            completion: @escaping (Result<[Spacing], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        request(model: [Spacing].self,
                from: "projects/\(projectId)/spacing_tokens?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)",
                completion: completion)
    }
}

// MARK: - Styleguide-Specific APIs
public extension ZeplinAPI {
    /// Fetch a specific styleguide
    ///
    /// - parameter id: The styleguide's ID
    /// - parameter completion: A completion handler which can result in a successful
    ///                         `Stylguide`, or a `ZeplinAPI.Error` error
    func getStyleguide(_ id: Styleguide.ID,
                       completion: @escaping (Result<Styleguide, Error>) -> Void) {
        request(model: Styleguide.self,
                from: "styleguides/\(id)",
                completion: completion)
    }

    /// Fetch all styleguides
    ///
    /// - parameter projectId: A Zeplin Project ID to fetch styleguides for
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                         of `Stylguide`s, or a `ZeplinAPI.Error` error
    func getStyleguides(for projectId: Project.ID? = nil,
                        page: Int = 1,
                        completion: @escaping (Result<[Styleguide], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        var path = "styleguides?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)"

        if let projectId = projectId {
            path.append("&linked_project=\(projectId)")
        }

        request(model: [Styleguide].self,
                from: path,
                completion: completion)
    }

    /// Fetch all colors associated with a specific Zeplin Styleguide
    ///
    /// - parameter styleguideID: A Zeplin Styleguide ID to fetch colors for
    /// - parameter linkedProject: The styleguide's linked project, if applicable
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///
    func getStyleguideColors(for styleguideID: Styleguide.ID,
                             linkedProject: Project.ID?,
                             page: Int = 1,
                             completion: @escaping (Result<[Color], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        var path = "styleguides/\(styleguideID)/colors?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)"

        if let linkedProject = linkedProject {
            path.append("&linked_project=\(linkedProject)")
        }

        request(model: [Color].self,
                from: path,
                completion: completion)
    }
    
    /// Fetch all text styles associated with a specific Zeplin Styleguide
    ///
    /// - parameter styleguideID: A Zeplin Styleguide ID to fetch text styles for
    /// - parameter linkedProject: The styleguide's linked project, if applicable
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `TextStyle`s, or a `ZeplinAPI.Error` error
    func getStyleguideTextStyles(for styleguideID: Styleguide.ID,
                                 linkedProject: Project.ID?,
                                 page: Int = 1,
                                 completion: @escaping (Result<[TextStyle], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        var path = "styleguides/\(styleguideID)/text_styles?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)"

        if let linkedProject = linkedProject {
            path.append("&linked_project=\(linkedProject)")
        }

        request(model: [TextStyle].self,
                from: path,
                completion: completion)
    }

    /// Fetch all spacing tokens associated with a specific Zeplin Styleguide
    ///
    /// - parameter styleguideID: A Zeplin Styleguide ID to fetch spacing tokens for
    /// - parameter linkedProject: The styleguide's linked project, if applicable
    /// - parameter page: The current results page to ask for, defaults to 1
    /// - parameter completion: A completion handler which can result in a successful array
    ///                          of `Spacing`s, or a `ZeplinAPI.Error` error
    func getStyleguideSpacings(for styleguideID: Styleguide.ID,
                               linkedProject: Project.ID?,
                               page: Int = 1,
                               completion: @escaping (Result<[Spacing], Error>) -> Void) {
        let offset = (page - 1) * ZeplinAPI.itemsPerPage
        var path = "styleguides/\(styleguideID)/spacing_tokens?offset=\(offset)&limit=\(ZeplinAPI.itemsPerPage)"

        if let linkedProject = linkedProject {
            path.append("&linked_project=\(linkedProject)")
        }

        request(model: [Spacing].self,
                from: path,
                completion: completion)
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
                        completion(.failure(.apiError(message: error.description)))
                    } catch {
                        completion(.failure(Error.unknownAPIError(statusCode: response.statusCode,
                                                                  url: request.url?.absoluteString ?? "N/A",
                                                                  message: "\(error)")))
                    }
                    return
                }
                
                do {
                    if let data = data {
                        try completion(.success(Model.decode(from: data,
                                                             keyDecodingStrategy: .convertFromSnakeCase)))
                    }
                } catch {
                    completion(.failure(Error.decodingFailed(type: Model.self,
                                                             message: "\(error)")))
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
        case decodingFailed(type: Decodable.Type, message: String)
        case unknownAPIError(statusCode: Int, url: String, message: String)
        case apiError(message: String)
        case compoundError(errors: [ZeplinAPI.Error])

        public var description: String {
            switch self {
            case .invalidRequestURL(let path):
                return "Failed constructing URL from path '\(path)'"
            case let .decodingFailed(type, description):
                return "Failed decoding \(type): \(description)"
            case let .unknownAPIError(statusCode, url, message):
                return "An unknown HTTP \(statusCode) API error to \(url) occured: \(message)"
            case .apiError(let message):
                return "Zeplin API Failure: \(message)"
            case .compoundError(let errors):
                return errors.map { $0.description }.joined(separator: "\n")
            }
        }
    }
    
    // Private struct used to parse Zeplin's API Error Model
    private struct APIError: Codable {
        let message: String
        let detail: String?
        let code: String?

        var description: String {
            return "\(message) (detail: \(code ?? "N/A"), code: \(code ?? "N/A"))"
        }
    }
}
