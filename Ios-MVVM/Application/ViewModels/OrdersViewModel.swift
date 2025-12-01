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
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let orderRepository: OrderRepositoryProtocol
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(orderRepository: OrderRepositoryProtocol, coordinator: Coordinator?) {
        self.orderRepository = orderRepository
        self.coordinator = coordinator

        Task {
            await loadOrders()
        }
    }

    // MARK: - Public Methods
    func loadOrders() async {
        isLoading = true
        errorMessage = nil

        do {
            orders = try await orderRepository.fetchOrders()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
    }

    func didSelectOrder(_ order: Order) {
        // In a real app, this would navigate to order detail
        print("Selected order: \(order.id)")
    }

    func retry() {
        Task {
            await loadOrders()
        }
    }
}

// MARK: - Routable
extension OrdersViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "ecommerce",
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
        let viewModel = OrdersViewModel(
            orderRepository: DIContainer.shared.orderRepository,
            coordinator: coordinator
        )
        return AnyView(OrdersView(viewModel: viewModel))
    }
}
