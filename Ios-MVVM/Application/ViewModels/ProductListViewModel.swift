//
//  ProductListViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Product List screen
//  Handles fetching products and navigation to detail
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ProductListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let productRepository: ProductRepositoryProtocol
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(productRepository: ProductRepositoryProtocol, coordinator: Coordinator?) {
        self.productRepository = productRepository
        self.coordinator = coordinator
    }

    // MARK: - Public Methods
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            products = try await productRepository.fetchProducts()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    func didSelectProduct(_ product: Product) {
        coordinator?.navigate(to: "https://myapp.com/products/\(product.id)")
    }

    func retry() {
        Task {
            await loadProducts()
        }
    }
}

// MARK: - Routable
extension ProductListViewModel: Routable {
    static var path: String { return "/products" }
    static var routeIdentifier: String {
        Route.productList.identifier
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .productList
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        guard let appCoordinator = coordinator as? AppCoordinator else {
            return AnyView(Text("Invalid coordinator").foregroundColor(.red))
        }
        let viewModel = ProductListViewModel(
            productRepository: appCoordinator.productRepository,
            coordinator: coordinator
        )
        return AnyView(ProductListView(viewModel: viewModel))
    }
}
