//
//  UserDetail.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

struct UserDetail: View {
    @State private var viewModel: UserDetailViewModel
        
    init(user: User) {
        _viewModel = State(initialValue: UserDetailViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            AsyncImage(
                url: .init(string: viewModel.user.profile_image)
            ) { image in
                image.resizable().scaledToFit().onAppear {
                    viewModel.setImage(image)
                }
            } placeholder: {
                ProgressView()
            }
            Text(viewModel.user.display_name)
            
            if viewModel.isProcessing {
                ProgressView()
                    .progressViewStyle(.circular)
            } else if let result = viewModel.result {
                Text("Result: \(result)")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                Button("Process") {
                    Task {
                        await viewModel.processImage()
                    }
                }
            }
        }
    }
}

#Preview("UserDetail") {
    UserDetail(user: .testUser1)
}

#Preview("Processing") {
    let vm = UserDetailViewModel(user: .testUser1)
    vm.isProcessing = true
    return UserDetail(user: .testUser1)
}

#Preview("Result") {
    let vm = UserDetailViewModel(user: .testUser1)
    vm.result = "Found face!"
    return UserDetail(user: .testUser1)
}

#Preview("Error") {
    let vm = UserDetailViewModel(user: .testUser1)
    vm.error = NSError(domain: "com.toyapp", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
    return UserDetail(user: .testUser1)
}
