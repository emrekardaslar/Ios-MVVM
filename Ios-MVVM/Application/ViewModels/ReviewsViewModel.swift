//
//  ReviewsViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Reviews screen
//

import Foundation
import Combine
import SwiftUI

struct Review: Identifiable, Hashable {
    let id = UUID()
    let productName: String
    let rating: Double
    let comment: String
    let author: String
    let date: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

@MainActor
class ReviewsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var reviews: [Review] = []

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadReviews()
    }

    // MARK: - Public Methods
    func loadReviews() {
        // Mock data
        reviews = [
            Review(
                productName: "Fjallraven Backpack",
                rating: 4.5,
                comment: "Great quality! Very durable and stylish.",
                author: "John D.",
                date: Date().addingTimeInterval(-86400 * 5)
            ),
            Review(
                productName: "Mens Cotton Jacket",
                rating: 5.0,
                comment: "Perfect fit and amazing material!",
                author: "Sarah M.",
                date: Date().addingTimeInterval(-86400 * 3)
            ),
            Review(
                productName: "Casual T-Shirt",
                rating: 3.5,
                comment: "Good but runs a bit small.",
                author: "Mike R.",
                date: Date().addingTimeInterval(-86400 * 1)
            )
        ]
    }
}

// MARK: - Routable
extension ReviewsViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "ecommerce",
            path: "/reviews"
        )
    }

    static func createView(parameters: [String: String], coordinator: Coordinator) -> AnyView {
        let viewModel = ReviewsViewModel(coordinator: coordinator)
        return AnyView(ReviewsView(viewModel: viewModel))
    }
}
