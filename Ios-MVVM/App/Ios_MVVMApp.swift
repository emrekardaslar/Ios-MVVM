//
//  Ios_MVVMApp.swift
//  Ios-MVVM
//
//  Main App entry point
//  Wires up DI Container and Coordinator
//

import SwiftUI

@main
struct Ios_MVVMApp: App {
    @StateObject private var coordinator: AppCoordinator

    init() {
        let container = DIContainer.shared
        let coordinator = AppCoordinator(container: container)
        container.setCoordinator(coordinator)
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(route: .productList)
                    .navigationDestination(for: Route.self) { route in
                        coordinator.build(route: route)
                    }
            }
            .environmentObject(coordinator)
        }
    }
}
