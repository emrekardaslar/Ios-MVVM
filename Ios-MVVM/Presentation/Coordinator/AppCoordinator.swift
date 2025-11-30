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
    @Published var currentActivity: Activity = .ecommerce
    @Published var currentTab: Tab = .home
    @Published private(set) var paths: [Tab: NavigationPath] = [:]

    // MARK: - Private Properties
    private let container: DIContainer
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

    // MARK: - Activity Management
    func switchActivity(to activity: Activity) {
        currentActivity = activity
        currentTab = activity.defaultTab
    }

    // MARK: - URL-Based Navigation
    func navigate(to url: URL) {
        guard let (activity, tab, route) = urlRouter.route(from: url) else {
            print("⚠️ Could not parse URL: \(url)")
            return
        }

        // Switch activity if different
        if activity != currentActivity {
            currentActivity = activity
        }

        // Switch tab if specified and belongs to current activity
        if let tab = tab, tab.activity == currentActivity {
            currentTab = tab
        }

        // Navigate to route
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

    // MARK: - View Builder
    @MainActor
    func build(route: Route) -> AnyView {
        // Use the auto-generated map to find the ViewModel for this route
        if let viewModelType = routableTypeMap[route.identifier] {
            return viewModelType.createView(from: route, coordinator: self)
        }

        return AnyView(Text("No ViewModel found for route: \(route.identifier)").foregroundColor(.red))
    }
}
