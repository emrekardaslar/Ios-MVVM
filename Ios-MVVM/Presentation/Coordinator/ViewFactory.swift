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
        coordinator.register(route: .home) {
            let viewModel = HomeViewModel(coordinator: coordinator)
            HomeView(viewModel: viewModel)
        }

        // Products Tab
        coordinator.register(route: .productList) {
            let viewModel = ProductListViewModel(
                productRepository: coordinator.productRepository,
                coordinator: coordinator
            )
            ProductListView(viewModel: viewModel)
        }

        // Favorites Tab
        coordinator.register(route: .favorites) {
            let viewModel = FavoritesViewModel(coordinator: coordinator)
            FavoritesView(viewModel: viewModel)
        }

        // Orders (navigated from Home)
        coordinator.register(route: .orders) {
            let viewModel = OrdersViewModel(coordinator: coordinator)
            OrdersView(viewModel: viewModel)
        }

        // Note: .productDetail is handled separately in AppCoordinator.build()
        // because it has an associated value (Product)
    }
}
