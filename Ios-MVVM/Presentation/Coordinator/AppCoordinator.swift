//
//  AppCoordinator.swift
//  Ios-MVVM
//
//  Created by Emre Kardaşlar on 20.11.2025.
//


//
//  AppCoordinator.swift
//  Ios-MVVM
//
//  Manages app-wide navigation using NavigationStack
//

import SwiftUI

class AppCoordinator: ObservableObject, Coordinator {
    // MARK: - Published Properties
    @Published var currentTab: Tab = .home
    @Published private(set) var paths: [Tab: NavigationPath] = [:]

    // MARK: - Private Properties
    private let container: DIContainer
    private var viewBuilders: [Route: @MainActor () -> AnyView] = [:]

    // MARK: - Initialization
    init(container: DIContainer) {
        self.container = container
        // Initialize paths for all tabs
        Tab.allCases.forEach { tab in
            paths[tab] = NavigationPath()
        }
    }

    // MARK: - Navigation Methods
    func navigate(to route: Route) {
        paths[currentTab]?.append(route)
    }

    func pop() {
        guard var path = paths[currentTab], !path.isEmpty else { return }
        path.removeLast()
        paths[currentTab] = path
    }

    func popToRoot() {
        paths[currentTab] = NavigationPath()
    }

    // MARK: - Path Binding Helper
    func binding(for tab: Tab) -> Binding<NavigationPath> {
        Binding(
            get: { self.paths[tab] ?? NavigationPath() },
            set: { self.paths[tab] = $0 }
        )
    }

    // MARK: - Registration
    @MainActor
    func register<V: View>(route: Route, @ViewBuilder builder: @escaping () -> V) {
        viewBuilders[route] = { AnyView(builder()) }
    }

    // MARK: - View Builder
    @MainActor
    @ViewBuilder
    func build(route: Route) -> some View {
        // Handle routes with associated values first
        switch route {
        case .productDetail(let product):
            let viewModel = ProductDetailViewModel(product: product, coordinator: self)
            ProductDetailView(viewModel: viewModel)
        default:
            // Use registered builders
            if let builder = viewBuilders[route] {
                builder()
            } else {
                Text("Route not registered: \(String(describing: route))")
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Dependency Access
    var productRepository: ProductRepositoryProtocol {
        container.productRepository
    }
}
