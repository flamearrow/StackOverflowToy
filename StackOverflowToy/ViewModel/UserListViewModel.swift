//
//  UserListViewModel.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

@Observable class UserListViewModel {
    var users: [User] = [
        .testUser1,
        .testUser2,
        .testUser3,
        .testUser4
    ]
    
}
