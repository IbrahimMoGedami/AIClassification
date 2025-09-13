//
//  ImageClassifier.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import Foundation
import SwiftUI
import CoreML
import Vision
import UIKit

@Observable
class ImageClassifier {
    
    var classificationResult: String = ""
    
    private var model: VNCoreMLModel
    
    init() {
        do {
            let config = MLModelConfiguration()
            let model = try MobileNetV2(configuration: config).model
            self.model = try VNCoreMLModel(for: model)
        } catch {
            fatalError("Failed to load Core ML model: \(error)")
        }
    }
    
    deinit {
        debugPrint("\(String(describing: self)) DEINIT FROM MEMORY.")
    }
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self,
                  let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first
            else { return }
            DispatchQueue.main.async {
                self.classificationResult = topResult.identifier
            }
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        try? handler.perform([request])
    }
    
}
