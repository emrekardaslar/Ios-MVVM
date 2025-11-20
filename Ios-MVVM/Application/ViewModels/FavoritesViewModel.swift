//
//  FavoritesViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Favorites screen
//

import Foundation
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var favoriteProducts: [Product] = []

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadFavorites()
    }

    // MARK: - Public Methods
    func loadFavorites() {
        // For now, using mock data
        // In a real app, this would load from UserDefaults, CoreData, or a favorites service
        favoriteProducts = [
            Product.mockList[0],
            Product.mockList[2]
        ]
    }

    func didSelectProduct(_ product: Product) {
        coordinator?.navigate(to: .productDetail(product))
    }

    func removeFavorite(_ product: Product) {
        favoriteProducts.removeAll { $0.id == product.id }
    }
}
