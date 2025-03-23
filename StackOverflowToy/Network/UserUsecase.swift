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

class UserUsecase {
    private let moyaProvider = MoyaProvider<StackOverflowAPI>()
    
    func fetchTopUsers(page: Int, pageSize: Int = 10) -> AnyPublisher<UserResponse, MoyaError> {
        return moyaProvider.requestPublisher(
            .getTopUsers(page: page, pageSize: pageSize)
        )
        .map(UserResponse.self)
        .eraseToAnyPublisher()
    }
    
}
