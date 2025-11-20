//
//  HomeView.swift
//  Ios-MVVM
//
//  Home screen with welcome message and quick actions
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                welcomeSection

                quickActionsSection

                statsSection

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Home")
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back,")
                .font(.title2)
                .foregroundColor(.secondary)

            Text(viewModel.userName)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 16) {
                QuickActionCard(
                    icon: "bag.fill",
                    title: "Browse Products",
                    color: .blue
                ) {
                    viewModel.navigateToProducts()
                }

                QuickActionCard(
                    icon: "heart.fill",
                    title: "Favorites",
                    color: .red
                ) {
                    // Future: Navigate to favorites
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)

            HStack(spacing: 16) {
                StatCard(
                    icon: "cart.fill",
                    title: "Orders",
                    value: "12",
                    color: .green
                )

                StatCard(
                    icon: "star.fill",
                    title: "Reviews",
                    value: "8",
                    color: .orange
                )

                StatCard(
                    icon: "creditcard.fill",
                    title: "Saved",
                    value: "$245",
                    color: .purple
                )
            }
        }
    }
}

// MARK: - Quick Action Card Component
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(coordinator: nil)
        )
    }
}
