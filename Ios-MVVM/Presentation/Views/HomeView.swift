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

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)

            HStack(spacing: 16) {
                StatCard(
                    icon: "cart.fill",
                    title: "Orders",
                    value: "12",
                    color: .green,
                    action: {
                        viewModel.navigateToOrders()
                    }
                )
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
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
