//
//  WelcomeView.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import SwiftUI

struct WelcomeView: View {
    
    @State private var navigateToClassification = false
    @State private var navigateToImageOriantation = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // App Icon/Logo
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 150, height: 150)
                        )
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("AI Image Classifier")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Discover what's in your photos")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Features List
                    VStack(alignment: .leading, spacing: 15) {
                        FeatureRow(icon: "sparkles", text: "AI-powered image recognition")
                        FeatureRow(icon: "percent", text: "Confidence percentage scoring")
                        FeatureRow(icon: "clock", text: "Classification history tracking")
                        FeatureRow(icon: "photo", text: "High-quality image processing")
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Get Started Button
                    Button(action: {
                        navigateToClassification = true
                    }) {
                        HStack {
                            Text("Get Started")
                                .font(.title2.weight(.semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)
                    
                    Button(action: {
                        navigateToImageOriantation = true
                    }) {
                        HStack {
                            Text("Clean Your Image")
                                .font(.title2.weight(.semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .padding(.top, 50)
            }
        }
        .navigationDestination(isPresented: $navigateToClassification) {
            ImageClassificationView()
                .navigationBarBackButtonHidden(false)
        }
        
        .navigationDestination(isPresented: $navigateToImageOriantation) {
            ImageSegmentationView()
                .navigationBarBackButtonHidden(false)
        }
    }
}

struct FeatureRow: View {
    
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .foregroundColor(.white.opacity(0.9))
                .font(.body)
            
            Spacer()
        }
    }

}

#Preview {
    WelcomeView()
}
