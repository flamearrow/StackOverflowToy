//
//  UserdetailsViewModel.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Foundation
import SwiftUI
import Vision

@Observable class UserDetailViewModel {
    let user: User
    var isProcessing = false
    var result: String?
    var error: Error?
    
    private var imageBuffer: CVPixelBuffer?
    
    private let faceDetector: FaceDetectorProtocol
    
    init(user: User, faceDetector: FaceDetectorProtocol = FaceDetector()) {
        self.user = user
        self.faceDetector = faceDetector
    }
    
    @MainActor func setImage(_ image: Image) {
        self.imageBuffer = image.asUIImage()?.toPixelBuffer()
    }
    
    func processImage() async {
        guard let imageBuffer = self.imageBuffer else {
            print("image not available")
            return
        }
        
        isProcessing = true
        error = nil
        result = ""
        
        let detectResult = await faceDetector.detectFaces(in: imageBuffer)
        print("result: \(detectResult)")
        detectResult.map(\.description).forEach {
            result! += $0
        }
        
        
        isProcessing = false
    }
}
