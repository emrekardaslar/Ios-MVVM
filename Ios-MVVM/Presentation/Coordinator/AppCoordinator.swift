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
    @Published var path = NavigationPath()
    private let container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    func navigate(to route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path = NavigationPath()
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
