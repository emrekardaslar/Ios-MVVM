//
//  ActivitySwitcherView.swift
//  Ios-MVVM
//
//  Activity switcher menu component
//  Shows available activities (E-Commerce, Brochure) in a menu
//

import SwiftUI

struct ActivitySwitcherView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var showingMenu = false

    var body: some View {
        Menu {
            ForEach(Activity.allCases, id: \.self) { activity in
                Button(action: {
                    coordinator.switchActivity(to: activity)
                }) {
                    HStack {
                        Text(activity.displayName)

                        if coordinator.currentActivity == activity {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 20))
                Text("Apps")
                    .font(.caption2)
            }
            .foregroundColor(showingMenu ? .blue : .primary)
        }
        .onChange(of: showingMenu) { _, newValue in
            // This is just for visual feedback
        }
    }
}

// MARK: - Preview
#Preview {
    let container = DIContainer.shared
    let coordinator = AppCoordinator(container: container)

    return ActivitySwitcherView(coordinator: coordinator)
}
