//
//  RouteConfig.swift
//  Ios-MVVM
//
//  Configuration for route navigation including activity, tab, path, and auth requirements
//

import Foundation

/// Defines a tab's visual appearance and identifier
struct TabConfig {
    let identifier: String  // Tab identifier (becomes enum case: "home", "products", etc.)
    let icon: String        // SF Symbol name (e.g., "house.fill", "bag.fill")
    let index: Int          // Tab order in the tab bar (0, 1, 2, etc.)

    init(identifier: String, icon: String, index: Int) {
        self.identifier = identifier
        self.icon = icon
        self.index = index
    }
}

struct RouteConfig {
    let activity: String    // Activity identifier: "ecommerce", "brochure", etc.
    let tab: TabConfig?     // Tab configuration with styling
    let path: String
    let requiresAuth: Bool

    init(activity: String, tab: TabConfig? = nil, path: String, requiresAuth: Bool = false) {
        self.activity = activity
        self.tab = tab
        self.path = path
        self.requiresAuth = requiresAuth
    }
}
