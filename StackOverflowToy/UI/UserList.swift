//
//  UserList.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

struct UserList: View {
    @State var vm = UserListViewModel()
    
    var body: some View {
       NavigationStack {
           List(vm.users) { user in
               NavigationLink(value: user) {
                   UserRow(user: user)
               }
           }
           .navigationDestination(for: User.self) { user in
               UserDetail(user: user)
           }
       }
    }
}

#Preview {
    UserList()
}
