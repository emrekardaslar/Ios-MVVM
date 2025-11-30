//
//  ProductDetailViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Product Detail screen
//  Displays detailed product information
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ProductDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var product: Product?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let productRepository: ProductRepositoryProtocol
    private weak var coordinator: Coordinator?
    private let productId: Int

    // MARK: - Initialization
    init(productId: Int, productRepository: ProductRepositoryProtocol, coordinator: Coordinator?) {
        self.productId = productId
        self.productRepository = productRepository
        self.coordinator = coordinator

        // Fetch product data
        Task {
            await loadProduct()
        }
    }

    // MARK: - Computed Properties
    var formattedPrice: String {
        guard let product = product else { return "" }
        return String(format: "$%.2f", product.price)
    }

    var formattedRating: String {
        guard let product = product else { return "" }
        return String(format: "%.1f ⭐️ (%d reviews)", product.rating.rate, product.rating.count)
    }

    // MARK: - Private Methods
    private func loadProduct() async {
        isLoading = true
        errorMessage = nil

        do {
            product = try await productRepository.fetchProduct(id: productId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load product: \(error.localizedDescription)"
        }
    }

    // MARK: - Public Methods
    func goBack() {
        coordinator?.pop()
    }
}

// MARK: - Routable
extension ProductDetailViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "ecommerce",
            path: "/products/:id"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let idParam = parameters["id"], let productId = Int(idParam) else {
            return nil
        }
        return .productDetail(id: productId)
    }

    static func extractParameters(from route: Route) -> [String: String] {
        if case .productDetail(let id) = route {
            return ["id": "\(id)"]
        }
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        if case .productDetail(let id) = route {
            let viewModel = ProductDetailViewModel(
                productId: id,
                productRepository: DIContainer.shared.productRepository,
                coordinator: coordinator
            )
            return AnyView(ProductDetailView(viewModel: viewModel))
        } else {
            return AnyView(Text("Invalid route for ProductDetail").foregroundColor(.red))
        }
    }
}
