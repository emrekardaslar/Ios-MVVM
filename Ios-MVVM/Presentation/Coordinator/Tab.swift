//
//  Tab.swift
//  Ios-MVVM
//
//  Defines bottom navigation tabs for each activity
//

import SwiftUI

enum Tab: String, CaseIterable {
    // E-commerce activity tabs
    case home
    case products
    case favorites

    // Brochure activity tabs
    case brochures

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .products:
            return "Products"
        case .favorites:
            return "Favorites"
        case .brochures:
            return "Brochures"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .products:
            return "bag.fill"
        case .favorites:
            return "heart.fill"
        case .brochures:
            return "book.fill"
        }
    }

    var activity: Activity {
        switch self {
        case .home, .products, .favorites:
            return .ecommerce
        case .brochures:
            return .brochure
        }
    }

    var rootRoute: Route {
        switch self {
        case .home:
            return .home
        case .products:
            return .productList
        case .favorites:
            return .favorites
        case .brochures:
            return .brochures
        }
    }

    static func tabs(for activity: Activity) -> [Tab] {
        allCases.filter { $0.activity == activity }
    }
}
