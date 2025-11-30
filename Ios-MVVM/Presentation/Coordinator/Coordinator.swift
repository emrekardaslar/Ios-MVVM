//
//  Coordinator.swift
//  Ios-MVVM
//
//  Coordinator protocol for navigation
//  Uses URL-based navigation for unified routing
//

import Foundation

@MainActor
protocol Coordinator: AnyObject {
    // MARK: - Basic Navigation
    func pop()
    func popToRoot()

    // MARK: - URL-Based Navigation
    /// Navigate to a screen using a URL
    /// Supports both custom scheme (myapp://) and universal links (https://myapp.com)
    ///
    /// Automatically switches to the correct tab if the ViewModel declares one in its RouteConfig
    /// Detail views (without tab config) open in the current tab
    ///
    /// Examples:
    /// - myapp://products → Switches to Products tab (has tab in config)
    /// - myapp://products/123 → Opens in current tab (detail view, no tab config)
    /// - https://myapp.com/orders → Opens in current tab (no tab config)
    /// - https://myapp.com/favorites → Switches to Favorites tab (has tab in config)
    func navigate(to url: URL)

    /// Navigate to a screen using a URL string
    /// Convenience method that converts string to URL
    func navigate(to urlString: String)
}
