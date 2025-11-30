//
//  OrdersView.swift
//  Ios-MVVM
//
//  Orders screen displaying user's order history
//

import SwiftUI

struct OrdersView: View {
    @StateObject var viewModel: OrdersViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading orders...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        viewModel.retry()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else if viewModel.orders.isEmpty {
                emptyState
            } else {
                ordersList
            }
        }
        .navigationTitle("My Orders")
        .navigationBarTitleDisplayMode(.large)
    }

    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.orders) { order in
                    OrderCard(order: order) {
                        viewModel.didSelectOrder(order)
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "basket")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Orders Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Your order history will appear here")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Order Card Component
struct OrderCard: View {
    let order: Order
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id)")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(order.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    StatusBadge(status: order.status)
                }

                Divider()

                // Items
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(order.items) { item in
                        HStack {
                            Text(item.productName)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("×\(item.quantity)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                // Total
                HStack {
                    Text("Total")
                        .font(.headline)

                    Spacer()

                    Text(order.formattedTotal)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Status Badge Component
struct StatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color(for: status))
            .cornerRadius(8)
    }

    private func color(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OrdersView(
            viewModel: OrdersViewModel(
                orderRepository: DIContainer.shared.orderRepository,
                coordinator: nil
            )
        )
    }
}
