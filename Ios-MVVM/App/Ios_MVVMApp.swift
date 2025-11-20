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

        // Register all views with the coordinator (must happen before StateObject creation)
        MainActor.assumeIsolated {
            ViewFactory.registerViews(coordinator: coordinator)
        }

        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some Scene {
        WindowGroup {
            TabBarView(coordinator: coordinator)
        }
    }
}
