//
//  FaceDetector.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Vision
import OSLog
protocol FaceDetectorProtocol {
    func detectFaces(in image: CVPixelBuffer) async throws -> [VNFaceObservation]
}

struct FaceDetector : FaceDetectorProtocol {
    static let shared = FaceDetector()
    
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceDetectionHandler = VNSequenceRequestHandler()
    
    func detectFaces(in image: CVPixelBuffer) async throws -> [VNFaceObservation] {
        try await Task.detached {
            #if targetEnvironment(simulator)
            if #available(iOS 17.0, *) {
                let allDevices = MLComputeDevice.allComputeDevices
                
                for device in allDevices {
                    if device.description.contains("MLCPUComputeDevice") {
                        faceDetectionRequest.setComputeDevice(.some(device), for: .main)
                        break
                    }
                }
            } else {
                faceDetectionRequest.usesCPUOnly = true
            }
            #endif
            try self.faceDetectionHandler.perform([self.faceDetectionRequest], on: image)
            return faceDetectionRequest.results ?? []
        }.value
    }
}
