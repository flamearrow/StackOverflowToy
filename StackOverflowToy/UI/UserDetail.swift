//
//  UserDetail.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

struct UserDetail: View {
    let user: User
    var body: some View {
        AsyncImage(url: .init(string: user.profile_image))
    }
}

#Preview {
    UserDetail(user: .testUser1)
}
