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

class TopUserFetcher {
    static let defaultPageSize = 10
    
    let pageSize: Int
    
    init(pageSize: Int = defaultPageSize) {
        self.pageSize = pageSize
    }
    
    private let moyaProvider = MoyaProvider<StackOverflowAPI>()
    
    func fetchTopUsers(page: Int) -> AnyPublisher<UserResponse, MoyaError> {
        return moyaProvider.requestPublisher(
            .getTopUsers(page: page, pageSize: pageSize)
        )
        .map(UserResponse.self)
        .eraseToAnyPublisher()
    }
    
}
