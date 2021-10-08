//
//  ZeplinAPI.swift
//  Prism
//
//  Created by Shai Mishali on 13/12/2019.
//  Copyright © 2019 Gett. All rights reserved.
//

import Foundation
import ProviderCore
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Zeplin's API Interface
public class FigmaAPI: ProviderAPI {
    private let accessToken: String
    
    public static var baseURL: URL {
        .init(string: "https://api.figma.com/v1/")!
    }

    /// Instantiate an instance of the Figma API with a
    /// provided Access token
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}

// MARK: - File-specific APIs
public extension FigmaAPI {
    /// Fetch the entirety of the file and its various nodes from Figma
    ///
    /// - parameter key: Filter by project status
    /// - parameter completion: A completion handler which can result in a successful result
    ///                          of `File`, or a `FigmaAPI.Error` error
    func getFile(key: String,
                 completion: @escaping (Result<File, Error>) -> Void) {
        request(model: File.self,
                from: "files/\(key)",
                completion: completion)
    }
}

// MARK: - Private Helpers
private extension FigmaAPI {
    func request<Model: Decodable>(
        model: Model.Type,
        from path: String,
        completion: @escaping (Result<Model, Error>
        ) -> Void
    ) {
        let apiURL = Self.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: apiURL)
        request.addValue(accessToken, forHTTPHeaderField: "X-Figma-Token")

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
                        try completion(.success(
                            Model.decode(
                                from: data,
                                keyDecodingStrategy: .convertFromSnakeCase,
                                dateDecodingStrategy: .iso8601
                            )
                        ))
                    }
                } catch {
                    completion(.failure(Error.decodingFailed(type: Model.self,
                                                             message: "\(error)")))
                }
            }
            .resume()
    }
}

public extension FigmaAPI {
    enum Error: Swift.Error, CustomStringConvertible {
        case decodingFailed(type: Decodable.Type, message: String)
        case unknownAPIError(statusCode: Int, url: String, message: String)
        case apiError(message: String)
        case compoundError(errors: [FigmaAPI.Error])

        public var description: String {
            switch self {
            case let .decodingFailed(type, description):
                return "Failed decoding \(type): \(description)"
            case let .unknownAPIError(statusCode, url, message):
                return "An unknown HTTP \(statusCode) API error to \(url) occured: \(message)"
            case .apiError(let message):
                return "Figma API Failure: \(message)"
            case .compoundError(let errors):
                return errors.map(\.description).joined(separator: "\n")
            }
        }
    }
}

private extension FigmaAPI {
    // Private struct used to parse Figma's API Error Model
    struct APIError: Codable {
        let message: String
        let code: Int

        var description: String {
            return "\(message) (\(code))"
        }

        enum CodingKeys: String, CodingKey {
            case message = "err"
            case code = "status"
        }
    }
}
