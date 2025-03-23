//
//  FaceDetector.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Vision

protocol FaceDetectorProtocol {
    @MainActor
    func detectFaces(in image: CVPixelBuffer) async -> [VNFaceObservation]
}

struct FaceDetector : FaceDetectorProtocol {
    private let faceDetectionRequest = VNDetectFaceRectanglesRequest()
    private let faceDetectionHandler = VNSequenceRequestHandler()
    
    func detectFaces(in image: CVPixelBuffer) async -> [VNFaceObservation] {
        await Task.detached(priority: .userInitiated) {
            do {
                #if targetEnvironment(simulator)
                    if #available(iOS 17.0, *) {
                      let allDevices = MLComputeDevice.allComputeDevices

                      for device in allDevices {
                        if(device.description.contains("MLCPUComputeDevice")){
                            faceDetectionRequest.setComputeDevice(.some(device), for: .main)
                          break
                        }
                      }

                    } else {
                      // Fallback on earlier versions
                        faceDetectionRequest.usesCPUOnly = true
                    }
                #endif
                
                try faceDetectionHandler.perform([faceDetectionRequest], on: image)
                return faceDetectionRequest.results ?? []
            } catch {
                print("Failed to detect faces: \(error)")
                return []
            }
        }.value
    }
}
