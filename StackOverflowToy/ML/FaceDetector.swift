//
//  FaceDetector.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Vision
import OSLog
protocol FaceDetectorProtocol {
    func detectFaces(in image: CVPixelBuffer) async -> [VNFaceObservation]
}

struct FaceDetector : FaceDetectorProtocol {
    static let shared = FaceDetector()
    
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceDetectionHandler = VNSequenceRequestHandler()
    
    func detectFaces(in image: CVPixelBuffer) async -> [VNFaceObservation] {
        return await withCheckedContinuation { continuation in
            Task {
                do {
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
                    continuation.resume(returning: faceDetectionRequest.results ?? [])
                } catch {
                    Logger.faceDetector.error("Failed to detect faces: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
