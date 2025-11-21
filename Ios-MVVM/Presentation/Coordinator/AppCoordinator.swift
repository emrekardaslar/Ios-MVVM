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

@MainActor
class AppCoordinator: ObservableObject, Coordinator {
    // MARK: - Published Properties
    @Published var currentTab: Tab = .home
    @Published private(set) var paths: [Tab: NavigationPath] = [:]

    // MARK: - Private Properties
    private let container: DIContainer
    private var viewBuilders: [String: @MainActor (Route) -> AnyView] = [:]
    private let urlRouter = URLRouter()

    // MARK: - Initialization
    init(container: DIContainer) {
        self.container = container
        // Initialize paths for all tabs
        Tab.allCases.forEach { tab in
            paths[tab] = NavigationPath()
        }
    }

    // MARK: - Navigation Methods
    private func navigate(to route: Route) {
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

    // MARK: - URL-Based Navigation
    func navigate(to url: URL) {
        guard let route = urlRouter.route(from: url) else {
            print("⚠️ Could not parse URL: \(url)")
            return
        }
        navigate(to: route)
    }

    func navigate(to urlString: String) {
        guard let url = URL(string: urlString) else {
            print("⚠️ Invalid URL string: \(urlString)")
            return
        }
        navigate(to: url)
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
    func register<V: View>(identifier: String, @ViewBuilder builder: @escaping (Route) -> V) {
        viewBuilders[identifier] = { route in AnyView(builder(route)) }
    }

    // MARK: - View Builder
    @MainActor
    @ViewBuilder
    func build(route: Route) -> some View {
        if let builder = viewBuilders[route.identifier] {
            builder(route)
        } else {
            Text("Route not registered: \(route.identifier)")
                .foregroundColor(.red)
        }
    }

    // MARK: - Dependency Access
    var productRepository: ProductRepositoryProtocol {
        container.productRepository
    }
}
