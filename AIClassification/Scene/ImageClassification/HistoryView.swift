//
//  HistoryView.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import SwiftUI

struct HistoryView: View {
    
    let history: [ClassificationResult]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if history.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Your classification history will appear here")
                    )
                } else {
                    List {
                        ForEach(history) { result in
                            HistoryRow(result: result)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Classification History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

}

struct HistoryRow: View {
    let result: ClassificationResult
    
    var body: some View {
        HStack(spacing: 16) {
            // Confidence Indicator
            Circle()
                .fill(confidenceColor(result.confidence))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.className)
                    .font(.body)
                    .lineLimit(1)
                
                Text("\(Int(result.confidence * 100))% confident • \(result.timestamp, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func confidenceColor(_ confidence: Double) -> Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}
