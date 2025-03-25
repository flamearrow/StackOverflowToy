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
    case incorrectViewStateError(required: String, actual: String)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return NSLocalizedString("Failed to convert image", comment: "Error when image conversion fails")
        case .noImageAvailable:
            return NSLocalizedString("No image available", comment: "Error when trying to process without an image")
        case .incorrectViewStateError(let required, let actual):
            return NSLocalizedString("Invalid state: required \(required), got \(actual)", comment: "Error when view state is incorrect")
        }
    }
}

@Observable class UserDetailViewModel {
    
    private(set) var viewState: UserDetailViewState
    
    private let faceDetector: FaceDetectorProtocol
    
    init(user: User, faceDetector: FaceDetectorProtocol) {
        self.viewState = .loading(user: user)
        self.faceDetector = faceDetector
    }
    
    func reset(user: User) {
        self.viewState = .loading(user: user)
    }
    
    @MainActor func setImage(_ image: Image) {
        guard case .loading(let user) = viewState else {
            viewState = .error(
                user: viewState.getUser(),
                error: UserDetailError.incorrectViewStateError(
                    required: "loading", actual: "type(of: viewState)"
                )
            )
            return
        }
        
        viewState = .loaded(user: user, image: image)
    }
    
    @MainActor func processImage() async {
        let (user, image): (User, Image)
        switch(viewState) {
        case .loaded(let u, let i):
            (user, image) = (u, i)
        case .result(let u, let i, _, _):
            (user, image) = (u, i)
        default:
            viewState = .error(
                user: viewState.getUser(),
                error: UserDetailError.incorrectViewStateError(
                    required: "loaded or result", actual: viewState.name()
                )
            )
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
            viewState = .error(user: user, error: error)
        }
    }
}

// MARK: - extensions
private extension UserDetailViewState {
    func name() -> String {
        switch(self) {
        case .loading(user: _):
            "loading"
        case .loaded(user: _, image: _):
            "loaded"
        case .processing(user: _, image: _):
            "processing"
        case .result(user: _, image: _, confidence: _, boundingBox: _):
            "result"
        case .error(user: _, error: _):
            "error"
        }
    }
}
