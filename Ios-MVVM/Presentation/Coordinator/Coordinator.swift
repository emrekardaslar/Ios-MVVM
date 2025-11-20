//
//  Coordinator.swift
//  Ios-MVVM
//
//  Protocol defining navigation capabilities
//

import Foundation

protocol Coordinator: AnyObject {
    // MARK: - Basic Navigation
    func pop()
    func popToRoot()

    // MARK: - Intent-Based Navigation
    func showProduct(_ product: Product)
    func showProducts()
    func showOrders()
    func showReviews()
}
