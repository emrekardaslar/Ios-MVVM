//
//  NetworkService.swift
//  Ios-MVVM
//
//  Handles HTTP requests using URLSession with async/await
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: String, method: HTTPMethod) async throws -> T
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL: String
    private let session: URLSession

    init(baseURL: String = "https://fakestoreapi.com", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<T: Decodable>(endpoint: String, method: HTTPMethod = .get) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error)
            }

        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
