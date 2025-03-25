//
//  Logger+Extension.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/25/25.
//
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let faceDetector = Logger(subsystem: subsystem, category: "faceDetector")
    
    static let userListViewModel = Logger(subsystem: subsystem, category: "userListViewModel")
    
    static let topUserFetcher = Logger(subsystem: subsystem, category: "topUserFetcher")
}
