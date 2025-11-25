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
    @Published var brochures: [Brochure] = []

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
        brochures = Brochure.mockList
    }

    func didSelectBrochure(_ brochure: Brochure) {
        guard let url = URL(string: "https://myapp.com/brochures/\(brochure.id)") else { return }
        coordinator?.navigate(to: url)
    }
}

// MARK: - Routable
extension BrochuresViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: .brochure,
            tab: nil,
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
