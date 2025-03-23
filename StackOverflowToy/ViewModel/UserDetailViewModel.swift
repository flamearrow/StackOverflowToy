//
//  UserdetailsViewModel.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Foundation
import SwiftUI
import Vision

private enum UserDetailError: LocalizedError {
    case imageConversionFailed
    case noImageAvailable
    case incorrectViewStateError
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return NSLocalizedString("Failed to convert image", comment: "Error when image conversion fails")
        case .noImageAvailable:
            return NSLocalizedString("No image available", comment: "Error when trying to process without an image")
        case .incorrectViewStateError:
            return NSLocalizedString("Invalid view state", comment: "Error when view state is incorrect")
        }
    }
}

@Observable class UserDetailViewModel {
    
    var viewState: UserDetailViewState

    private let faceDetector: FaceDetectorProtocol
    
    init(user: User, faceDetector: FaceDetectorProtocol = FaceDetector()) {
        self.viewState = .loading(user: user)
        self.faceDetector = faceDetector
    }
    
    @MainActor func setImage(_ image: Image) {
        guard case .loading(let user) = viewState else {
            print("current state is not loaded, but got \(String(describing: viewState))")
            viewState = .error(errr: UserDetailError.incorrectViewStateError)
            return
        }
        
        viewState = .loaded(user: user, image: image)
    }
    
    @MainActor func processImage() async {
        guard case .loaded(let user, let image) = viewState else {
            print("current state is not loaded, but \(String(describing: viewState))")
            viewState = .error(errr: UserDetailError.incorrectViewStateError)
            return
        }
        
        viewState = .processing(user: user, image: image)
        
        do {
            guard let uiImage = image.asUIImage(), let buffer = uiImage.toPixelBuffer() else {
                throw UserDetailError.imageConversionFailed
            }
            
            let detectResult = await faceDetector.detectFaces(in: buffer)
            if let firstFace = detectResult.first {
                viewState = .result(
                    user: user,
                    image: image,
                    confidence: Double(firstFace.confidence),
                    boundingBox: firstFace.boundingBox
                )
            } else {
                viewState = .result(
                    user: user,
                    image: image,
                    confidence: nil,
                    boundingBox: nil
                )
            }
        } catch {
            viewState = .error(errr: error)
        }
    }
}
