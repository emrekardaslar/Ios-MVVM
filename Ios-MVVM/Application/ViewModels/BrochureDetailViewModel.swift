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
    @Published var brochure: Brochure

    // MARK: - Dependencies
    private weak var coordinator: Coordinator?

    // MARK: - Initialization
    init(brochure: Brochure, coordinator: Coordinator?) {
        self.brochure = brochure
        self.coordinator = coordinator
    }

    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: brochure.publishedDate)
    }

    // MARK: - Public Methods
    func downloadPDF() {
        // In a real app, this would download the PDF
        print("Downloading PDF from: \(brochure.pdfUrl)")
    }

    func shareBrochure() {
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

    static func createView(parameters: [String: String], coordinator: Coordinator) -> AnyView {
        guard let idParam = parameters["id"], let brochureId = Int(idParam) else {
            return AnyView(Text("Invalid brochure ID").foregroundColor(.red))
        }
        // In a real app, fetch from repository
        let brochure = Brochure.mockList.first { $0.id == brochureId } ?? Brochure.mock
        let viewModel = BrochureDetailViewModel(brochure: brochure, coordinator: coordinator)
        return AnyView(BrochureDetailView(viewModel: viewModel))
    }
}
