//
//  ImageClassificationView.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import SwiftUI

struct ImageClassificationView: View {
    
    @State private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var isClassifying = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var confidence: Double = 0.0
    @State private var showConfidence = false
    @State private var classificationHistory: [ClassificationResult] = []
    @State private var showHistory = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Image Display
                    imageSection
                    
                    // Results Card
                    if !classifier.classificationResult.isEmpty {
                        resultsCard
                    }
                    
                    // Action Buttons
                    actionButtons
                    
                    // History Preview
                    if !classificationHistory.isEmpty {
                        historyPreview
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Classify Image")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive, action: clearAll) {
                        Label("Clear All", systemImage: "trash")
                    }
                    
                    if !classificationHistory.isEmpty {
                        Button(action: { showHistory = true }) {
                            Label("View History", systemImage: "clock")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage) { image in
                classifyImage(image)
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(history: classificationHistory)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isClassifying {
                loadingOverlay
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("AI Image Classification")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            
            Text("Upload an image to identify objects using AI")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var imageSection: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .frame(width: geometry.size.width - 32) // Use GeometryReader for dynamic sizing
                        .clipped()
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 280)
                        .frame(width: geometry.size.width - 32)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                    .symbolRenderingMode(.hierarchical)
                                
                                Text("Tap to select an image")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Supported formats: JPG, PNG, HEIC")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 300) // Set a fixed height for GeometryReader
        .onTapGesture {
            isImagePickerPresented = true
        }
        .animation(.spring(response: 0.6), value: selectedImage)
    }
    
    //    private var imageSection: some View {
    //        ZStack {
    //            if let image = selectedImage {
    //                Image(uiImage: image)
    //                    .resizable()
    //                    .scaledToFill()
    //                    .frame(height: 280)
    //                    .frame(maxWidth: .infinity)
    //                    .cornerRadius(20)
    //                    .overlay(
    //                        RoundedRectangle(cornerRadius: 20)
    //                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
    //                    )
    //                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    //            } else {
    //                RoundedRectangle(cornerRadius: 20)
    //                    .fill(Color.white)
    //                    .frame(height: 280)
    //                    .overlay(
    //                        VStack(spacing: 16) {
    //                            Image(systemName: "photo.badge.plus")
    //                                .font(.system(size: 50))
    //                                .foregroundColor(.blue)
    //                                .symbolRenderingMode(.hierarchical)
    //                            
    //                            Text("Tap to select an image")
    //                                .font(.headline)
    //                                .foregroundColor(.primary)
    //                            
    //                            Text("Supported formats: JPG, PNG, HEIC")
    //                                .font(.caption)
    //                                .foregroundColor(.secondary)
    //                        }
    //                    )
    //                    .overlay(
    //                        RoundedRectangle(cornerRadius: 20)
    //                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
    //                    )
    //            }
    //        }
    //        .onTapGesture {
    //            isImagePickerPresented = true
    //        }
    //        .animation(.spring(response: 0.6), value: selectedImage)
    //    }
    
    private var resultsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Classification Result")
                    .font(.headline)
                
                Spacer()
                
                if showConfidence {
                    Text("\(Int(confidence * 100))%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(confidenceColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(confidenceColor.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            
            Text(classifier.classificationResult)
                .font(.title3.weight(.medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if showConfidence {
                VStack(spacing: 8) {
                    HStack {
                        Text("Confidence Level")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(confidenceText)
                            .font(.caption)
                            .foregroundColor(confidenceColor)
                    }
                    
                    ProgressView(value: confidence)
                        .tint(confidenceColor)
                        .animation(.easeInOut(duration: 0.8), value: confidence)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                isImagePickerPresented = true
            }) {
                Label(selectedImage == nil ? "Choose Image" : "Change Image", systemImage: "photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            if selectedImage != nil {
                Button(action: {
                    if let image = selectedImage {
                        classifyImage(image)
                    }
                }) {
                    if isClassifying {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Analyze", systemImage: "sparkles")
                            .font(.headline)
                    }
                }
                .frame(height: 54)
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isClassifying)
            }
        }
    }
    
    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Classifications")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    showHistory = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(classificationHistory.prefix(3), id: \.id) { result in
                    HistoryRow(result: result)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.white)
                
                Text("Analyzing image...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("This may take a few seconds")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
    
    private var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
    
    private var confidenceText: String {
        switch confidence {
        case 0.8...1.0: return "High confidence"
        case 0.6..<0.8: return "Moderate confidence"
        default: return "Low confidence"
        }
    }
    
    private func classifyImage(_ image: UIImage) {
        isClassifying = true
        showConfidence = false
        
        classifier.classifyImage(image) { result, confidence in
            isClassifying = false
            showConfidence = true
            self.confidence = confidence
            
            let classification = ClassificationResult(
                className: result,
                confidence: confidence,
                timestamp: Date(),
                image: image
            )
            classificationHistory.append(classification)
        }
    }
    
    private func clearAll() {
        selectedImage = nil
        classifier.classificationResult = ""
        showConfidence = false
        confidence = 0.0
        classificationHistory.removeAll()
    }
    
}

#Preview {
    ImageClassificationView()
}
