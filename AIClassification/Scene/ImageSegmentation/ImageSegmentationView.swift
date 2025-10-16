//
//  ImageSegmentationView.swift
//  AIClassification
//
//  Created by Ibrahim Mo Gedami on 14/09/2025.
//

import SwiftUI

struct ImageSegmentationView: View {
    
    var viewModel = ImageSegmentationViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    if let image = viewModel.inputImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    Spacer()
                    
                    if let image = viewModel.outputImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                
                Button {
                    viewModel.runVisionRequest()
                } label: {
                    Text("Run Image Segmentation")
                    
                }
                .padding()
            }
            .ignoresSafeArea()
        }
    }

}

#Preview {
    ImageSegmentationView()
}
