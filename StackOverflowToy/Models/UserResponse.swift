//
//  UserResponse.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import Foundation

struct UserResponse: Decodable {
    let items: [User]
    let has_more: Bool
    let backoff: Int? // Wait this many seconds to make another call
    let quota_max: Int
    let quota_remaining: Int
}
