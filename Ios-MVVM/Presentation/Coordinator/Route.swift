//
//  Route.swift
//  Ios-MVVM
//
//  Defines all possible navigation routes in the app
//

import Foundation

enum Route: Hashable {
    case productList
    case productDetail(Product)
}
