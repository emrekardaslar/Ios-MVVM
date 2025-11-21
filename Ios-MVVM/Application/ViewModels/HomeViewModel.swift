//
//  HomeViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Home screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = "User"

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
    }

    // MARK: - Public Methods
    func navigateToProducts() {
        coordinator?.navigate(to: "https://myapp.com/products")
    }

    func navigateToOrders() {
        coordinator?.navigate(to: "https://myapp.com/orders")
    }

    func navigateToReviews() {
        coordinator?.navigate(to: "https://myapp.com/reviews")
    }
}

// MARK: - Routable
extension HomeViewModel: Routable {
    static var routeIdentifier: String {
        Route.home.identifier
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = HomeViewModel(coordinator: coordinator)
        return AnyView(HomeView(viewModel: viewModel))
    }
}
