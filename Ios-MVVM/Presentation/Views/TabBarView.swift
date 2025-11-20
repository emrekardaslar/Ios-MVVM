//
//  TabBarView.swift
//  Ios-MVVM
//
//  Main tab bar navigation component
//

import SwiftUI

struct TabBarView: View {
    @StateObject private var coordinator: AppCoordinator
    @State private var selectedTab: Tab = .home

    init(coordinator: AppCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationStack(path: $coordinator.path) {
                    coordinator.build(route: tab.rootRoute)
                        .navigationDestination(for: Route.self) { route in
                            coordinator.build(route: route)
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
    }
}
