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
    
    func classifyImage(_ image: UIImage, completion: ((String, Double) -> Void)? = nil) {
        guard let ciImage = CIImage(image: image) else {
            completion?("Failed to process image", 0.0)
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.classificationResult = "Error: \(error.localizedDescription)"
                    completion?(self.classificationResult, 0.0)
                }
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.classificationResult = "No results found"
                    completion?(self.classificationResult, 0.0)
                }
                return
            }
            
            DispatchQueue.main.async {
                let formattedResult = topResult.identifier.capitalized
                self.classificationResult = formattedResult
                completion?(formattedResult, Double(topResult.confidence))
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(image.imageOrientation))
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.classificationResult = "Classification failed: \(error.localizedDescription)"
                    completion?(self.classificationResult, 0.0)
                }
            }
        }
    }
    
}
