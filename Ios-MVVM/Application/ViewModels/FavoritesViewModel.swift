//
//  FavoritesViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Favorites screen
//

import Foundation
import Combine
import SwiftUI

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
        coordinator?.navigate(to: "https://myapp.com/products/\(product.id)")
    }

    func removeFavorite(_ product: Product) {
        favoriteProducts.removeAll { $0.id == product.id }
    }
}

// MARK: - Routable
extension FavoritesViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: .favorites,
            path: "/favorites"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .favorites
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func canHandle(route: Route) -> Bool {
        if case .favorites = route { return true }
        return false
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = FavoritesViewModel(coordinator: coordinator)
        return AnyView(FavoritesView(viewModel: viewModel))
    }
}
