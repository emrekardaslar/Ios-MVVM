//
//  Coordinator.swift
//  Ios-MVVM
//
//  Protocol defining navigation capabilities
//

import Foundation

protocol Coordinator: AnyObject {
    func navigate(to route: Route)
    func pop()
    func popToRoot()
}
