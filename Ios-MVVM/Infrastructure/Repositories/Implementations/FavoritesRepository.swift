//
//  FavoritesRepository.swift
//  Ios-MVVM
//
//  Concrete implementation of FavoritesRepositoryProtocol
//  Handles favorites data through NetworkService
//

import Foundation

class FavoritesRepository: FavoritesRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchFavorites() async throws -> [Product] {
        return try await networkService.request(endpoint: "/favorites", method: .get)
    }

    func addFavorite(productId: Int) async throws {
        // In a real app, this would POST to /favorites
        _ = try await networkService.request(endpoint: "/favorites/\(productId)", method: .post) as String
    }

    func removeFavorite(productId: Int) async throws {
        // In a real app, this would DELETE from /favorites
        _ = try await networkService.request(endpoint: "/favorites/\(productId)", method: .delete) as String
    }
}

// MARK: - Mock Repository for Testing/Preview
class MockFavoritesRepository: FavoritesRepositoryProtocol {
    var shouldFail: Bool = false
    var mockFavorites: [Product] = [
        Product.mockList[0],
        Product.mockList[2]
    ]

    func fetchFavorites() async throws -> [Product] {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockFavorites
    }

    func addFavorite(productId: Int) async throws {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 300_000_000)
        if let product = Product.mockList.first(where: { $0.id == productId }) {
            mockFavorites.append(product)
        }
    }

    func removeFavorite(productId: Int) async throws {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 300_000_000)
        mockFavorites.removeAll { $0.id == productId }
    }
}
