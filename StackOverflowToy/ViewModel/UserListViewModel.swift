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
    let userUsecase = UserUsecase()
    
    var users: [User] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUsers(page: Int, pageSize: Int = 10) {
        userUsecase
            .fetchTopUsers(page: page, pageSize: pageSize)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else {return}
                print("mlgb! fetchUsers failed: \(error)")
            } receiveValue: { [weak self] userResponse in
                self?.users = userResponse.items
                print("mlgb! remaining: \(userResponse.quota_remaining), ")
            }
            .store(in: &cancellables)
    }
    
}
