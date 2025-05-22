//
//  CozeClient.swift
//  VoiceAgent
//
//  Created by subs on 2025/4/17.
//

import UIKit

public class CozeClient {
    public let token: String
    public let botId: String
    public let baseURL: String
    public let session: URLSession

    public init(token: String, botId: String, baseURL: String?, session: URLSession = .shared) {
        self.token = token
        self.botId = botId
        self.baseURL = baseURL ?? "https://api.coze.cn"
        self.session = session
    }

    public func get<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(method: "GET", path: path, queryItems: queryItems, body: Optional<Data>.none, completion: completion)
    }

    public func post<T: Decodable, U: Encodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: U,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let data = try JSONEncoder().encode(body)
            request(method: "POST", path: path, queryItems: queryItems, body: data, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    public func put<T: Decodable, U: Encodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: U,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let data = try JSONEncoder().encode(body)
            request(method: "PUT", path: path, queryItems: queryItems, body: data, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    public func delete<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        request(method: "DELETE", path: path, queryItems: queryItems, body: Optional<Data>.none, completion: completion)
    }

    private func request<T: Decodable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Data?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let fullURLString: String
        if path.hasPrefix("http://") || path.hasPrefix("https://") {
            fullURLString = path
        } else {
            fullURLString = baseURL + path
        }

        var components = URLComponents(string: fullURLString)
        components?.queryItems = queryItems
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        session.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
