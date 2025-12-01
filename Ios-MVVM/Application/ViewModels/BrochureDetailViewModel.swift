//
//  BrochureDetailViewModel.swift
//  Ios-MVVM
//
//  ViewModel for Brochure Detail screen
//

import Foundation
import Combine
import SwiftUI

@MainActor
class BrochureDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var brochure: Brochure?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let brochureRepository: BrochureRepositoryProtocol
    private weak var coordinator: Coordinator?
    private let brochureId: Int

    // MARK: - Initialization
    init(brochureId: Int, brochureRepository: BrochureRepositoryProtocol, coordinator: Coordinator?) {
        self.brochureId = brochureId
        self.brochureRepository = brochureRepository
        self.coordinator = coordinator

        // Fetch brochure data
        Task {
            await loadBrochure()
        }
    }

    // MARK: - Computed Properties
    var formattedDate: String {
        guard let brochure = brochure else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: brochure.publishedDate)
    }

    // MARK: - Private Methods
    private func loadBrochure() async {
        isLoading = true
        errorMessage = nil

        do {
            brochure = try await brochureRepository.fetchBrochure(id: brochureId)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load brochure: \(error.localizedDescription)"
        }
    }

    // MARK: - Public Methods
    func downloadPDF() {
        guard let brochure = brochure else { return }
        // In a real app, this would download the PDF
        print("Downloading PDF from: \(brochure.pdfUrl)")
    }

    func shareBrochure() {
        guard let brochure = brochure else { return }
        // In a real app, this would open share sheet
        print("Sharing brochure: \(brochure.title)")
    }

    func goBack() {
        coordinator?.pop()
    }
}

// MARK: - Routable
extension BrochureDetailViewModel: Routable {
    static var routeConfig: RouteConfig {
        RouteConfig(
            activity: "brochure",
            path: "/brochures/:id"
        )
    }

    static func createRoute(from parameters: [String: String]) -> Route? {
        guard let idParam = parameters["id"], let brochureId = Int(idParam) else {
            return nil
        }
        return .brochureDetail(id: brochureId)
    }

    static func extractParameters(from route: Route) -> [String: String] {
        if case .brochureDetail(let id) = route {
            return ["id": "\(id)"]
        }
        return [:]
    }

    static func createView(from route: Route, coordinator: Coordinator) -> AnyView {
        if case .brochureDetail(let id) = route {
            let viewModel = BrochureDetailViewModel(
                brochureId: id,
                brochureRepository: DIContainer.shared.brochureRepository,
                coordinator: coordinator
            )
            return AnyView(BrochureDetailView(viewModel: viewModel))
        } else {
            return AnyView(Text("Invalid route for BrochureDetail").foregroundColor(.red))
        }
    }
}
