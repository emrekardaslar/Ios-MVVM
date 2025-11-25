//
//  Activity.swift
//  Ios-MVVM
//
//  Represents different activities/modules within the app
//  Activities are global and represent different app contexts (e.g., e-commerce, brochure)
//

import Foundation

enum Activity: String, Codable, CaseIterable {
    case ecommerce
    case brochure

    var displayName: String {
        switch self {
        case .ecommerce:
            return "E-Commerce"
        case .brochure:
            return "Brochure"
        }
    }

    var icon: String {
        switch self {
        case .ecommerce:
            return "cart.fill"
        case .brochure:
            return "book.fill"
        }
    }

    var defaultTab: Tab {
        switch self {
        case .ecommerce:
            return .home
        case .brochure:
            return .brochures
        }
    }
}
