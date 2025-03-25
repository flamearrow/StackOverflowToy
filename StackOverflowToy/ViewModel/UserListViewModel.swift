//
//  UserListViewModel.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI
import Combine
import CombineMoya
import OSLog

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
        case .idle, .error(_):
            (prevUsers, nextPage, hasMore) = ([], 1, true)
        case .loading:
            Logger.userListViewModel.info("can't fetch in loading state")
            return
        case .result(let users, let previousPage, let prevHasMore):
            (prevUsers, nextPage, hasMore) = (users, previousPage + 1, prevHasMore)
        }
        if(!hasMore) {
            Logger.userListViewModel.info("no more items")
            return
        }
        
        Logger.userListViewModel.info("Fetching page \(nextPage)")
        state = .loading(prevUsers)
        Task.detached(priority: .userInitiated) {
            self.topUserFetcher
                .fetchTopUsers(page: nextPage)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    guard case .failure(let error) = completion else {return}
                    self.state = .error(error.localizedDescription)
                } receiveValue: { [weak self] userResponse in
                    Logger.userListViewModel.info("Got resposne for page \(nextPage), hasMore: \(userResponse.has_more), quota_remaining: \(userResponse.quota_remaining), quota_max: \(userResponse.quota_max)")
                    self?.state = .result(prevUsers + userResponse.items, nextPage, userResponse.has_more)
                }
                .store(in: &self.cancellables)
        }
    }
    
}
