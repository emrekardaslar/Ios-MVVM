//
//  ProductRepository.swift
//  Ios-MVVM
//
//  Concrete implementation of ProductRepositoryProtocol
//  Handles product data fetching through NetworkService
//

import Foundation

class ProductRepository: ProductRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProducts() async throws -> [Product] {
        return try await networkService.request(endpoint: "/products", method: .get)
    }

    func fetchProduct(id: Int) async throws -> Product {
        return try await networkService.request(endpoint: "/products/\(id)", method: .get)
    }
}

// MARK: - Mock Repository for Testing/Preview
class MockProductRepository: ProductRepositoryProtocol {
    var shouldFail: Bool = false
    var mockProducts: [Product] = Product.mockList

    func fetchProducts() async throws -> [Product] {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return mockProducts
    }

    func fetchProduct(id: Int) async throws -> Product {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockProducts.first(where: { $0.id == id }) ?? Product.mock
    }
}
