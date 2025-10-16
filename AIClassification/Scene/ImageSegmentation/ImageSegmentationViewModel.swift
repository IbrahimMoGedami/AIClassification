//
//  ImageSegmentationViewModel.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 14/09/2025.
//

import SwiftUI
import CoreML
import Vision
import UIKit
import CoreMedia

@Observable
class ImageSegmentationViewModel {
    
    var outputImage: UIImage?
    var inputImage: UIImage?
    
    init() {
        outputImage = UIImage(named: "unsplash")
        inputImage = UIImage(named: "unsplash")
    }
    
    deinit {
        debugPrint("\(String(describing: self)) is DEINIT")
    }
    
    func runVisionRequest() {
        guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
        else { return }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self, error == nil else { return }
            self.visionRequestDidComplete(request: request, error: error)
        }
        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            guard let image = self.inputImage?.cgImage else { return }
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    func maskInputImage() {
        
        //        let points = [GradientPoint(location: 0, color: #colorLiteral(red: 0.6486759186, green: 0.2260715365, blue: 0.2819285393, alpha: 1)), GradientPoint(location: 0.2, color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 0.5028884243)), GradientPoint(location: 0.4, color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 0.3388534331)),
        //                  GradientPoint(location: 0.6, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 0.3458681778)), GradientPoint(location: 0.8, color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 0.3388534331))]
        //
        //        let bgImage = UIImage(size: self.inputImage.size, gradientPoints: points, scale: self.inputImage.scale)!
        guard let size = self.inputImage?.size,
            let scale = self.inputImage?.scale
        else { return }
        let bgImage = UIImage.imageFromColor(color: .orange, size: size, scale: scale)
        
        guard let beginCGImage = inputImage?.cgImage,
              let bgCGImage = bgImage?.cgImage,
              let maskCGImage = self.outputImage?.cgImage
        else { return }
        
        let beginImage = CIImage(cgImage: beginCGImage)
        let background = CIImage(cgImage: bgCGImage)
        let mask = CIImage(cgImage: maskCGImage)
        
        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: beginImage,
            kCIInputBackgroundImageKey:background,
            kCIInputMaskImageKey:mask])?.outputImage
        {
            
            
            let ciContext = CIContext(options: nil)
            
            let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            
            self.inputImage = UIImage(cgImage: filteredImageRef!)
            
        }
    }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                
                let segmentationMask = segmentationmap.image(min: 0, max: 1)
                guard let size = self.inputImage?.size else { return }
                self.outputImage = segmentationMask?.resizedImage(for: size)
                self.maskInputImage()
            }
        }
    }
    
}
