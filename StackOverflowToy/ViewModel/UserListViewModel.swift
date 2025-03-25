//
//  UserListViewModel.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI
import Combine
import CombineMoya

@Observable class UserListViewModel {
    let topUserFetcher: TopUserFetcherProtocol
    
    init(topUserFetcher: TopUserFetcherProtocol) {
        self.topUserFetcher = topUserFetcher
    }
    
    private(set) var state: UserListViewState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUsers() {
        let (prevUsers, nextPage, hasMore): ([User], Int, Bool)
        
        switch(state) {
        case .idle:
            (prevUsers, nextPage, hasMore) = ([], 1, true)
        case .error(_):
//            self.state = .error("can't fetch in error state")
            return
        case .loading:
//            self.state = .error("can't fetch in loading state")
            return
        case .result(let users, let previousPage, let prevHasMore):
            (prevUsers, nextPage, hasMore) = (users, previousPage + 1, prevHasMore)
        }
        if(!hasMore) {
            print("BGLM no more items")
            return
        }
        print("BGLM fetching page \(nextPage)")
        state = .loading(prevUsers)
        Task.detached(priority: .userInitiated) {
            // Manually wait 5 sec to throttle request
            try await Task.sleep(for: .seconds(5))
            self.topUserFetcher
                .fetchTopUsers(page: nextPage)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    guard case .failure(let error) = completion else {return}
                    self.state = .error(error.localizedDescription)
                } receiveValue: { [weak self] userResponse in
                    self?.state = .result(prevUsers + userResponse.items, nextPage, userResponse.has_more)
                }
                .store(in: &self.cancellables)
        }
    }
    
}
