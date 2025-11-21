//
//  RoutableRegistry.swift
//  Ios-MVVM
//
//  Central registry of all routable view models
//  To add a new route: implement Routable in your ViewModel and add its type here
//

import Foundation

@MainActor
class RoutableRegistry {
    /// All view models that can be routed to
    /// Add new routable types here when implementing new screens
    static let all: [any Routable.Type] = [
        HomeViewModel.self,
        ProductListViewModel.self,
        ProductDetailViewModel.self,
        FavoritesViewModel.self,
        OrdersViewModel.self,
        ReviewsViewModel.self
    ]

    /// Registers all routable types with the coordinator
    /// - Parameter coordinator: The coordinator to register routes with
    static func registerAll(with coordinator: AppCoordinator) {
        all.forEach { routableType in
            coordinator.register(identifier: routableType.routeIdentifier) { route in
                routableType.createView(from: route, coordinator: coordinator)
            }
        }
    }
}
