//
//  HomeViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Home screen
//

import Foundation
import Combine

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
        coordinator?.showProducts()
    }

    func navigateToOrders() {
        coordinator?.showOrders()
    }

    func navigateToReviews() {
        coordinator?.showReviews()
    }
}
