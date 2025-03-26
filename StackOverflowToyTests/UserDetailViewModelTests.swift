import XCTest
import Vision
import SwiftUI
@testable import StackOverflowToy

// MARK: - Mock Dependencies
final class MockFaceDetector: FaceDetectorProtocol {
    var shouldSucceed = true
    var mockResult: [VNFaceObservation] = []
    
    func detectFaces(in image: CVPixelBuffer) async -> [VNFaceObservation] {
        if shouldSucceed {
            return mockResult
        } else {
            return []
        }
    }
}

// MARK: - Tests
final class UserDetailViewModelTests: XCTestCase {
    var sut: UserDetailViewModel!
    var mockFaceDetector: MockFaceDetector!
    
    override func setUp() {
        super.setUp()
        mockFaceDetector = MockFaceDetector()
        
        sut = UserDetailViewModel(
            user: .testUser1,
            faceDetector: mockFaceDetector
        )
        
        sut.setImage(Image(systemName: "person.circle.fill"))
    }
    
    override func tearDown() {
        sut = nil
        mockFaceDetector = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(sut.viewState.name(), "loaded")
    }
    
    // MARK: - Face Detection Tests
    @MainActor
    func testSuccessfulFaceDetection() async {
        // Given
        let mockObservation = VNFaceObservation()
        mockFaceDetector.mockResult = [mockObservation]
        
        // When
        await sut.processImage()
        
        // Then
        XCTAssertEqual(sut.viewState.name(), "result")
        if case .result(let user, _, let confidence, let boundingBox) = sut.viewState {
            XCTAssertEqual(user.id, User.testUser1.id)
            XCTAssertNotNil(confidence)
            XCTAssertNotNil(boundingBox)
        } else {
            XCTFail("Expected result state")
        }
    }
    
    @MainActor
    func testFailedFaceDetection() async {
        // Given
        mockFaceDetector.shouldSucceed = false
        sut.setImage(Image(systemName: "person.circle.fill"))
        
        // When
        await sut.processImage()
        
        // Then
        XCTAssertEqual(sut.viewState.name(), "error")
        if case .error(let user, let error) = sut.viewState {
            XCTAssertEqual(user?.id, User.testUser1.id)
            XCTAssertTrue(error is UserDetailError)
        } else {
            XCTFail("Expected error state")
        }
    }
} 
