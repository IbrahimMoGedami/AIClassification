//
//  ClassificationResult.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 13/09/2025.
//

import UIKit

struct ClassificationResult: Identifiable, Equatable, Hashable {
    
    let id = UUID()
     let className: String
     let confidence: Double
     let timestamp: Date
     let image: UIImage?
    
}
