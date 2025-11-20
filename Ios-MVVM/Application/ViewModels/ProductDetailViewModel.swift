//
//  ProductDetailViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Product Detail screen
//  Displays detailed product information
//

import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var product: Product

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(product: Product, coordinator: Coordinator?) {
        self.product = product
        self.coordinator = coordinator
    }

    // MARK: - Computed Properties
    var formattedPrice: String {
        String(format: "$%.2f", product.price)
    }

    var formattedRating: String {
        String(format: "%.1f ⭐️ (%d reviews)", product.rating.rate, product.rating.count)
    }

    // MARK: - Public Methods
    func goBack() {
        coordinator?.pop()
    }
}
