//
//  BrochureRepository.swift
//  Ios-MVVM
//
//  Concrete implementation of BrochureRepositoryProtocol
//  Handles brochure data fetching through NetworkService
//

import Foundation

class BrochureRepository: BrochureRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchBrochures() async throws -> [Brochure] {
        return try await networkService.request(endpoint: "/brochures", method: .get)
    }

    func fetchBrochure(id: Int) async throws -> Brochure {
        return try await networkService.request(endpoint: "/brochures/\(id)", method: .get)
    }
}

// MARK: - Mock Repository for Testing/Preview
class MockBrochureRepository: BrochureRepositoryProtocol {
    var shouldFail: Bool = false
    var mockBrochures: [Brochure] = Brochure.mockList

    func fetchBrochures() async throws -> [Brochure] {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return mockBrochures
    }

    func fetchBrochure(id: Int) async throws -> Brochure {
        if shouldFail {
            throw NetworkError.unknown
        }
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockBrochures.first(where: { $0.id == id }) ?? Brochure.mock
    }
}
