//
//  Route.swift
//  Ios-MVVM
//
//  Defines all possible navigation routes in the app
//

import Foundation

enum Route: Hashable {
    case home
    case productList
    case productDetail(Product)
    case favorites
    case orders

    var identifier: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
}
