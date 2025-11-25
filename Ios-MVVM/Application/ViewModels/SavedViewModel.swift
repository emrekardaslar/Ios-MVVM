//
//  SavedViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Saved items screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SavedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var savedItems: [Product] = []
    @Published var isLoading: Bool = false

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadSavedItems()
    }

    // MARK: - Public Methods
    func loadSavedItems() {
        isLoading = true
        // Simulate API delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            // Mock data - in a real app, this would load from persistent storage
            self?.savedItems = [
                Product.mockList[0],
                Product.mockList[2]
            ]
            self?.isLoading = false
        }
    }

    func didSelectItem(_ product: Product) {
        coordinator?.navigate(to: "https://myapp.com/products/\(product.id)")
    }

    func removeItem(_ product: Product) {
        savedItems.removeAll { $0.id == product.id }
    }
}

// MARK: - Routable
extension SavedViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .ecommerce,
            tab: .home,
            path: "/saved"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .saved
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func canHandle(route: Route) -> Bool {
        if case .saved = route { return true }
        return false
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = SavedViewModel(coordinator: coordinator)
        return AnyView(SavedView(viewModel: viewModel))
    }
}
