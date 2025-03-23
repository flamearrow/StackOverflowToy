//
//  StackOverflowAPI.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import Moya
import Foundation

enum StackOverflowAPI {
    case getTopUsers(page: Int, pageSize: Int = 10)
    //    case getUser(page: Int, pageSize: Int)
}

extension StackOverflowAPI: TargetType {
    var baseURL: URL {
        return URL(string:"https://api.stackexchange.com/2.2")!
    }
    
    var path: String {
        switch(self) {
            
        case .getTopUsers(_, _):
            "/users"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTopUsers:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getTopUsers(let page, let pageSize):
            return .requestParameters(parameters: [
                "page": page,
                "pageSize": pageSize,
                "order": "desc",
                "sort": "reputation",
                "site": "stackoverflow"
            ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Accept": "application/json"]
    }
}
