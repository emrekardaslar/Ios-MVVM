//
//  BrochuresView.swift
//  Ios-MVVM
//
//  Brochures screen for the Brochure activity
//

import SwiftUI

struct BrochuresView: View {
    @StateObject var viewModel: BrochuresViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.brochures, id: \.self) { brochure in
                    BrochureCard(title: brochure)
                }
            }
            .padding()
        }
        .navigationTitle("Brochures")
    }
}

// MARK: - Brochure Card Component
struct BrochureCard: View {
    let title: String

    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .frame(width: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Tap to view details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BrochuresView(
            viewModel: BrochuresViewModel(coordinator: nil)
        )
    }
}
