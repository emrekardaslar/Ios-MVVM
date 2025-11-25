//
//  OrdersViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Orders screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class OrdersViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadOrders()
    }

    // MARK: - Public Methods
    func loadOrders() {
        isLoading = true
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.orders = Order.mockOrders
            self?.isLoading = false
        }
    }

    func didSelectOrder(_ order: Order) {
        // In a real app, this would navigate to order detail
        // For now, we'll just print
        print("Selected order: \(order.id)")
    }
}

// MARK: - Routable
extension OrdersViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: nil,
            path: "/orders"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .orders
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }


    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = OrdersViewModel(coordinator: coordinator)
        return AnyView(OrdersView(viewModel: viewModel))
    }
}
