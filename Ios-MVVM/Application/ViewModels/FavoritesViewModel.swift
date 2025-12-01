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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let favoritesRepository: FavoritesRepositoryProtocol
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(favoritesRepository: FavoritesRepositoryProtocol, coordinator: Coordinator?) {
        self.favoritesRepository = favoritesRepository
        self.coordinator = coordinator

        Task {
            await loadFavorites()
        }
    }

    // MARK: - Public Methods
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil

        do {
            favoriteProducts = try await favoritesRepository.fetchFavorites()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
        }
    }

    func didSelectProduct(_ product: Product) {
        coordinator?.navigate(to: "https://myapp.com/products/\(product.id)")
    }

    func removeFavorite(_ product: Product) {
        Task {
            do {
                try await favoritesRepository.removeFavorite(productId: product.id)
                favoriteProducts.removeAll { $0.id == product.id }
            } catch {
                errorMessage = "Failed to remove favorite: \(error.localizedDescription)"
            }
        }
    }

    func retry() {
        Task {
            await loadFavorites()
        }
    }
}

// MARK: - Routable
extension FavoritesViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "ecommerce",
            tab: TabConfig(identifier: "favorites", icon: "heart.fill", index: 2),
            path: "/favorites"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .favorites
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = FavoritesViewModel(
            favoritesRepository: DIContainer.shared.favoritesRepository,
            coordinator: coordinator
        )
        return AnyView(FavoritesView(viewModel: viewModel))
    }
}
