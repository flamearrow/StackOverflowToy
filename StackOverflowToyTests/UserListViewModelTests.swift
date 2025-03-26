import XCTest
import Combine
import Moya
@testable import StackOverflowToy

// MARK: - Mock Dependencies
final class MockTopUserFetcher: TopUserFetcherProtocol {
    var shouldSucceed = true
    var mockUsers: [User] = []
    var mockError: MoyaError?
    var mockDelay: TimeInterval = 0
    
    func fetchTopUsers(page: Int) -> AnyPublisher<UserResponse, MoyaError> {
        if shouldSucceed {
            let response = UserResponse(items: mockUsers, has_more: true, backoff: 0, quota_max: 300, quota_remaining: 100)
            return Just(response)
                .delay(for: .seconds(mockDelay), scheduler: DispatchQueue.main)
                .setFailureType(to: MoyaError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: mockError ?? .underlying(NSError(domain: "test", code: -1), nil))
                .delay(for: .seconds(mockDelay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Tests
final class UserListViewModelTests: XCTestCase {
    var sut: UserListViewModel!
    var mockFetcher: MockTopUserFetcher!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockFetcher = MockTopUserFetcher()
        cancellables = []
        
        sut = UserListViewModel(topUserFetcher: mockFetcher)
    }
    
    override func tearDown() {
        sut = nil
        mockFetcher = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Helper Functions
    private func name(_ state: UserListViewState) -> String {
        switch state {
        case .idle: return "idle"
        case .loading: return "loading"
        case .error: return "error"
        case .result: return "result"
        }
    }
    
    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(name(sut.state), "idle")
    }
    
    // Wait for the state to change
    // TODO: Not a good approach, instead need to consume the actual state value and assert
    private func waitForStateChange() async {
        var attempts = 0
        while name(sut.state) != "result" && attempts < 10 {
            try? await _Concurrency.Task.sleep(nanoseconds: 100_000_000) // 100ms
            attempts += 1
        }
    }
    
    // MARK: - Loading Tests
    func testSuccessfulLoad() async {
        // Given
        let mockUsers = [
            User.testUser1,
            User.testUser2,
            User.testUser3
        ]
        mockFetcher.mockUsers = mockUsers
        
        // When
        sut.fetchUsers()
        
        await waitForStateChange()
        
        // Then
        XCTAssertEqual(name(sut.state), "result")
        if case .result(let users, _, _) = sut.state {
            XCTAssertEqual(users.count, 3)
            XCTAssertEqual(users[0].id, User.testUser1.id)
            XCTAssertEqual(users[1].id, User.testUser2.id)
            XCTAssertEqual(users[2].id, User.testUser3.id)
        } else {
            XCTFail("Expected result state")
        }
    }
    
    @MainActor
    func testFailedLoad() async {
        // Given
        mockFetcher.shouldSucceed = false
        mockFetcher.mockError = .underlying(NSError(domain: "test", code: -1), nil)
        
        // When
        sut.fetchUsers()
        
        await waitForStateChange()
        
        // Then
        XCTAssertEqual(name(sut.state), "error")
        if case .error(let msg) = sut.state {
            XCTAssertEqual(msg, "The operation couldn’t be completed. (test error -1.)")
        } else {
            XCTFail("Expected error state")
        }
    }
    
    @MainActor
    func testLoadMoreUsers() async {
        // Given
        let firstPage = [User.testUser1, User.testUser2]
        let secondPage = [User.testUser3, User.testUser4]
        
        mockFetcher.mockUsers = firstPage
        sut.fetchUsers() // get first two
        await waitForStateChange()
        
        mockFetcher.mockUsers = secondPage
        
        // When
        sut.fetchUsers() // get second two
        await waitForStateChange()
        
        // Then
        // should have all four users
        XCTAssertEqual(name(sut.state), "result")
        if case .result(let users, _, _) = sut.state {
            XCTAssertEqual(users.count, 4)
            XCTAssertEqual(users[0].id, User.testUser1.id)
            XCTAssertEqual(users[1].id, User.testUser2.id)
            XCTAssertEqual(users[2].id, User.testUser3.id)
            XCTAssertEqual(users[3].id, User.testUser4.id)
        } else {
            XCTFail("Expected result state")
        }
    }
} 
