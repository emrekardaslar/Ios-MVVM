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
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let brochureRepository: BrochureRepositoryProtocol
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(brochureRepository: BrochureRepositoryProtocol, coordinator: Coordinator?) {
        self.brochureRepository = brochureRepository
        self.coordinator = coordinator

        Task {
            await loadBrochures()
        }
    }

    // MARK: - Public Methods
    func loadBrochures() async {
        isLoading = true
        errorMessage = nil

        do {
            brochures = try await brochureRepository.fetchBrochures()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load brochures: \(error.localizedDescription)"
        }
    }

    func didSelectBrochure(_ brochure: Brochure) {
        guard let url = URL(string: "https://myapp.com/brochures/\(brochure.id)") else { return }
        coordinator?.navigate(to: url)
    }

    func retry() {
        Task {
            await loadBrochures()
        }
    }
}

// MARK: - Routable
extension BrochuresViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "brochure",
            tab: TabConfig(identifier: "brochures", icon: "book.fill", index: 0),
            path: "/brochures"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        return .brochures
    }

    static func extractParameters(from route: Route) -> [String: String] {
        return [:]
    }


    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        let viewModel = BrochuresViewModel(
            brochureRepository: DIContainer.shared.brochureRepository,
            coordinator: coordinator
        )
        return AnyView(BrochuresView(viewModel: viewModel))
    }
}
