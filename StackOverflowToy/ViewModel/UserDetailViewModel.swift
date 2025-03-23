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
    
    init(user: User) {
        self.user = user
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
        result = nil
        
        do {
            try await Task.sleep(for: .seconds(2))
            result = "success! has face"
        } catch {
            self.error = error
        }
        
        isProcessing = false
    }
}
