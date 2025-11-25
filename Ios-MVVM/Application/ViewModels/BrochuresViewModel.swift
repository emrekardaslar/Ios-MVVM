//
//  BrochuresViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Brochures screen (Brochure activity)
//

import Foundation
import Combine
import SwiftUI

@MainActor
class BrochuresViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var brochures: [String] = []

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(coordinator: Coordinator?) {
        self.coordinator = coordinator
        loadBrochures()
    }

    // MARK: - Public Methods
    func loadBrochures() {
        // Mock data - in a real app, this would load from API/database
        brochures = [
            "Spring Collection 2024",
            "Summer Sale",
            "New Arrivals",
            "Holiday Catalog"
        ]
    }
}

// MARK: - Routable
extension BrochuresViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .brochure,
            tab: .brochures,
            path: "/brochures"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .brochures
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }

    static func canHandle(route: Route) -> Bool {
        if case .brochures = route { return true }
        return false
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = BrochuresViewModel(coordinator: coordinator)
        return AnyView(BrochuresView(viewModel: viewModel))
    }
}
