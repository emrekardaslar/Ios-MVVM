//
//  TabBarView.swift
//  Ios-MVVM
//
//  Main tab bar navigation component
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.currentTab) {
            ForEach(Tab.allCases, id: \.self) { tab in
                NavigationStack(path: coordinator.binding(for: tab)) {
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
