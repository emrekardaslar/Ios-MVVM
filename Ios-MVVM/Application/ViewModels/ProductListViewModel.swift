//
//  ProductListViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Product List screen
//  Handles fetching products and navigation to detail
//

import Foundation
import Combine

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
        coordinator?.navigate(to: .productDetail(product))
    }

    func retry() {
        Task {
            await loadProducts()
        }
    }
}
