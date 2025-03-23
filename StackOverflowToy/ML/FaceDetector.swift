//
//  FaceDetector.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Vision

protocol FaceDetectorProtocol {
    func detectFaces(in image: CVPixelBuffer) -> [VNFaceObservation]
}

struct FaceDetector : FaceDetectorProtocol {
    
    
    
    func detectFaces(in image: CVPixelBuffer) -> [VNFaceObservation] {
        return []
    }
    
    
}
