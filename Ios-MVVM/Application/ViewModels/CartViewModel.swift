//
//  CartViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Cart screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CartViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var cartItems: [Product] = []
    @Published var totalPrice: Double = 0.0

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadCart()
    }

    // MARK: - Public Methods
    func loadCart() {
        // Mock data - in a real app, this would load from a cart service
        cartItems = [
            Product.mockList[0],
            Product.mockList[1]
        ]
        calculateTotal()
    }

    func removeItem(_ product: Product) {
        cartItems.removeAll { $0.id == product.id }
        calculateTotal()
    }

    func checkout() {
        // Navigate to checkout flow
        coordinator?.navigate(to: "https://myapp.com/checkout")
    }

    private func calculateTotal() {
        totalPrice = cartItems.reduce(0) { $0 + $1.price }
    }
}

// MARK: - Routable
extension CartViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "ecommerce",
            tab: TabConfig(identifier: "cart", icon: "cart.fill", index: 3),
            path: "/cart"
        )
    }

    static func createView(parameters: [String: String], coordinator: Coordinator) -> AnyView {
        let viewModel = CartViewModel(coordinator: coordinator)
        return AnyView(CartView(viewModel: viewModel))
    }
}
