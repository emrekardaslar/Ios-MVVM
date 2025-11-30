//
//  OrderRepositoryProtocol.swift
//  Ios-MVVM
//
//  Protocol defining order data operations
//

import Foundation

protocol OrderRepositoryProtocol {
    func fetchOrders() async throws -> [Order]
    func fetchOrder(id: String) async throws -> Order
}
