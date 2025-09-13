//
//  ImageClassificationView.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import SwiftUI

struct ImageClassificationView: View {
    
    private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("Tap to select an image")
                    .foregroundStyle(.gray)
            }
            
            Button("Choose Image") {
                isImagePickerPresented = true
            }
            .padding()
            
            Text("Classification: \(classifier.classificationResult)")
                .font(.headline)
                .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage) { image in
                classifier.classifyImage(image)
            }
        }
    }

}

#Preview {
    ImageClassificationView()
}
