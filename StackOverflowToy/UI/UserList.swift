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
        UserListStateView(
            state: vm.state,
            onGetMoreUser: {
                vm.fetchUsers()
            }
        )
    }
}

private struct UserListStateView: View {
    let state: UserListViewState
    let onGetMoreUser: () -> Void
    
    var body: some View {
        Group {
            switch state {
            case .idle:
                Button("Load Top Users") {
                    onGetMoreUser()
                }
                .buttonStyle(PrimaryButtonStyle(icon: "arrow.clockwise"))
            case .error(let msg):
                VStack(spacing: 20) {
                    ErrorView(error: NSError(
                        domain: "com.stackOverflowToy",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: msg]
                    ))
                    Button("Try Again") {
                        onGetMoreUser()
                    }
                    .buttonStyle(PrimaryButtonStyle(icon: "arrow.clockwise"))
                }
            case .loading, .result:
                NavigationStack {
                    List {
                        ForEach(users) { user in
                            ScrollView {
                                NavigationLink(value: user) {
                                    UserRow(user: user)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .onAppear {
                                if(user.id == users.last?.id) {
                                    print("BGLM - should load more!")
                                    onGetMoreUser()
                                }
                            }
                        }
                        if showLoadingIndicator {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                Text("Loading more...")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .navigationDestination(for: User.self) { user in
                        UserDetail(user: user)
                    }
                }
            }
        }
    }
    
    private var users: [User] {
        switch state {
        case .loading(let users):
            return users
        case .result(let users, _, _):
            return users
        case .idle, .error:
            return []
        }
    }
    
    private var showLoadingIndicator: Bool {
        switch state {
        case .loading:
            return true
        case .result, .idle, .error:
            return false
        }
    }
}


// MARK: UserListViewState
enum UserListViewState {
    case idle
    case error(String)
    case loading([User])
    case result([User], Int, Bool) // users, previousPage, hasMore
}

// MARK: Previews
#Preview("Idle") {
    UserListStateView(state: .idle, onGetMoreUser: {})
}

#Preview("Loading") {
    UserListStateView(state: .loading(
        [
            .testUser1,
            .testUser2,
            .testUser3
        ]
    ), onGetMoreUser: {})
}

#Preview("Error") {
    UserListStateView(state: .error("Failed to fetch users"), onGetMoreUser: {})
}

#Preview("Result") {
    UserListStateView(
        state: .result(
            [
                .testUser1, .testUser2, .testUser3
            ],
            1,
            true
        ),
        onGetMoreUser: {}
    )
}
