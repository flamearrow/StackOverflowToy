//
//  GlobalDependencies.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/25/25.
//

import Foundation

class GlobalDependencies: ObservableObject {
    static let shared = GlobalDependencies(
        faceDetector: FaceDetector.shared,
        topUserFetcher: TopUserFetcher.shared
    )
    
    let faceDetector: FaceDetectorProtocol
    let topUserFetcher: TopUserFetcherProtocol
    
    init(faceDetector: FaceDetectorProtocol, topUserFetcher: TopUserFetcherProtocol) {
        self.faceDetector = faceDetector
        self.topUserFetcher = topUserFetcher
    }
}
