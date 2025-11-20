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

    private let container: DIContainer

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

    // MARK: - View Builders
    @MainActor
    @ViewBuilder
    func build(route: Route) -> some View {
        switch route {
        case .home:
            buildHomeView()
        case .productList:
            buildProductListView()
        case .productDetail(let product):
            buildProductDetailView(product: product)
        }
    }

    // MARK: - Private View Builders
    @MainActor
    private func buildHomeView() -> some View {
        let viewModel = HomeViewModel(coordinator: self)
        return HomeView(viewModel: viewModel)
    }

    @MainActor
    private func buildProductListView() -> some View {
        let viewModel = ProductListViewModel(
            productRepository: container.productRepository,
            coordinator: self
        )
        return ProductListView(viewModel: viewModel)
    }

    @MainActor
    private func buildProductDetailView(product: Product) -> some View {
        let viewModel = ProductDetailViewModel(
            product: product,
            coordinator: self
        )
        return ProductDetailView(viewModel: viewModel)
    }
}
