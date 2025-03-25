//
//  UserUsecase.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import Foundation
import Moya
import CombineMoya
import Combine

protocol TopUserFetcherProtocol {
    func fetchTopUsers(page: Int) -> AnyPublisher<UserResponse, MoyaError>
}

class TopUserFetcher: TopUserFetcherProtocol {
    static let shared = TopUserFetcher(pageSize: defaultPageSize)
    
    static let defaultPageSize = 10
    
    let pageSize: Int
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    private let moyaProvider = MoyaProvider<StackOverflowAPI>()
    
    func fetchTopUsers(page: Int) -> AnyPublisher<UserResponse, MoyaError> {
        return moyaProvider.requestPublisher(
            .getTopUsers(page: page, pageSize: pageSize)
        )
        .map(UserResponse.self)
        .handleEvents(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Error fetching users: \(error.localizedDescription)")
            }
        })
        .eraseToAnyPublisher()
    }
    
}
