//
//  RouteConfig.swift
//  Ios-MVVM
//
//  Configuration for route navigation including activity, tab, path, and auth requirements
//

import Foundation

struct RouteConfig {
    let activity: Activity
    let tab: Tab
    let path: String
    let requiresAuth: Bool

    init(activity: Activity, tab: Tab, path: String, requiresAuth: Bool = false) {
        self.activity = activity
        self.tab = tab
        self.path = path
        self.requiresAuth = requiresAuth
    }
}
