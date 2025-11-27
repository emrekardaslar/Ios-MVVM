//
//  CartView.swift
//  Ios-MVVM
//
//  Cart screen view
//

import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: CartViewModel

    var body: some View {
        VStack {
            if viewModel.cartItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Your cart is empty")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.cartItems, id: \.id) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(String(format: "$%.2f", item.price))
                                .font(.headline)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Section {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", viewModel.totalPrice))
                                .font(.title3)
                                .bold()
                        }
                    }
                }

                Button(action: {
                    viewModel.checkout()
                }) {
                    Text("Checkout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Cart")
    }
}

// MARK: - Preview
#Preview {
    let container = DIContainer.shared
    let coordinator = AppCoordinator(container: container)
    let viewModel = CartViewModel(coordinator: coordinator)

    return NavigationStack {
        CartView(viewModel: viewModel)
    }
}
