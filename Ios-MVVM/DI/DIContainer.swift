//
//  DIContainer.swift
//  Ios-MVVM
//
//  Dependency Injection Container
//  Holds and provides all app dependencies
//

import Foundation

class DIContainer {
    // MARK: - Services
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()

    // MARK: - Repositories
    lazy var productRepository: ProductRepositoryProtocol = {
        ProductRepository(networkService: networkService)
    }()

    lazy var brochureRepository: BrochureRepositoryProtocol = {
        BrochureRepository(networkService: networkService)
    }()

    // MARK: - Coordinator
    private(set) var coordinator: (any Coordinator)?

    func setCoordinator(_ coordinator: any Coordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Singleton
    static let shared = DIContainer()

    private init() {}
}

// MARK: - Mock Container for Previews/Testing
extension DIContainer {
    static var mock: DIContainer {
        let container = DIContainer()
        // Override with mock implementations
        return container
    }
}
