//
//  Tab.swift
//  Ios-MVVM
//
//  Defines bottom navigation tabs
//

import SwiftUI

enum Tab: String, CaseIterable {
    case home
    case products

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .products:
            return "Products"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .products:
            return "bag.fill"
        }
    }

    var rootRoute: Route {
        switch self {
        case .home:
            return .home
        case .products:
            return .productList
        }
    }
}
