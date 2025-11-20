//
//  ViewFactory.swift
//  Ios-MVVM
//
//  Registers all views with the coordinator
//  Single place to manage route → view mappings
//

import SwiftUI

@MainActor
class ViewFactory {

    // MARK: - Registration
    /// Registers all routes with their corresponding view builders
    /// This is the ONLY place you need to add new routes!
    static func registerViews(coordinator: AppCoordinator) {
        // Home Tab
        coordinator.register(identifier: Route.home.identifier) { _ in
            let viewModel = HomeViewModel(coordinator: coordinator)
            HomeView(viewModel: viewModel)
        }

        // Products Tab
        coordinator.register(identifier: Route.productList.identifier) { _ in
            let viewModel = ProductListViewModel(
                productRepository: coordinator.productRepository,
                coordinator: coordinator
            )
            ProductListView(viewModel: viewModel)
        }

        // Product Detail (extracts product from route)
        coordinator.register(identifier: Route.productDetail(Product.mock).identifier) { route in
            if case .productDetail(let product) = route {
                let viewModel = ProductDetailViewModel(product: product, coordinator: coordinator)
                ProductDetailView(viewModel: viewModel)
            } else {
                Text("Invalid route").foregroundColor(.red)
            }
        }

        // Favorites Tab
        coordinator.register(identifier: Route.favorites.identifier) { _ in
            let viewModel = FavoritesViewModel(coordinator: coordinator)
            FavoritesView(viewModel: viewModel)
        }

        // Orders (navigated from Home)
        coordinator.register(identifier: Route.orders.identifier) { _ in
            let viewModel = OrdersViewModel(coordinator: coordinator)
            OrdersView(viewModel: viewModel)
        }
    }
}
