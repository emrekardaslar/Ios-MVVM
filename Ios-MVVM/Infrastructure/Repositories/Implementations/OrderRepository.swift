//
//  OrderRepository.swift
//  Ios-MVVM
//
//  Concrete implementation of OrderRepositoryProtocol
//  Handles order data fetching through NetworkService
//

import Foundation

class OrderRepository: OrderRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchOrders() async throws -> [Order] {
        return try await networkService.request(endpoint: "/orders", method: .get)
    }

    func fetchOrder(id: String) async throws -> Order {
        return try await networkService.request(endpoint: "/orders/\(id)", method: .get)
    }
}

// MARK: - Mock Repository for Testing/Preview
class MockOrderRepository: OrderRepositoryProtocol {
    var shouldFail: Bool = false
    var mockOrders: [Order] = Order.mockOrders

    func fetchOrders() async throws -> [Order] {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return mockOrders
    }

    func fetchOrder(id: String) async throws -> Order {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000)
        guard let order = mockOrders.first(where: { $0.id == id }) else {
            throw NetworkError.unknown
        }
        return order
    }
}
