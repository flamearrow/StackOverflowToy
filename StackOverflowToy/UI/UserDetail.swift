//
//  UserDetail.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

enum UserDetailViewState {
    case loading(user: User)
    case loaded(user: User, image: Image)
    case processing(user: User, image: Image)
    case result(user: User, image: Image, confidence: Double?, boundingBox: CGRect?)
    case error(errr: Error)
    
    func getUser() -> User? {
        switch self {
        case .loading(let user),
             .loaded(let user, _),
             .processing(let user, _),
             .result(let user, _, _, _):
            return user
        case .error:
            return nil
        }
    }
    
    var image: Image? {
        switch self {
        case .loading:
            return nil
        case .loaded(_, let image),
             .processing(_, let image),
             .result(_, let image, _, _):
            return image
        case .error:
            return nil
        }
    }
}



struct UserDetail: View {
    @State private var viewModel: UserDetailViewModel
    
    init(user: User) {
        _viewModel = State(initialValue: UserDetailViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            UserDetailStateView(
                state: viewModel.viewState,
                onProcess: {
                    await viewModel.processImage()
                },
                onImageLoaded: { image in
                    viewModel.setImage(image)
                }
            )
        }
        .padding()
    }
}

struct UserDetailStateView: View {
    let state: UserDetailViewState
    let onProcess: () async -> Void
    let onImageLoaded: (Image) async -> Void
    
    var body: some View {
        
        Group {
            if let name = state.getUser()?.display_name {
                Text(name).font(.largeTitle)
            }
            switch state {
            case .loading(let user):
                AsyncImage(url: .init(string: user.profile_image)) { image in
                    image
                        .userDetailMainImageFrame()
                        .task {
                            await onImageLoaded(image)
                        }
                } placeholder: {
                    ProgressView()
                }
                
            case .loaded(_, let image):
                VStack {
                    image
                        .userDetailMainImageFrame()
                    Button("Detect") {
                        Task {
                            await onProcess()
                        }
                    }.padding()
                }
                
            case .processing(_, let image):
                VStack {
                    image
                        .userDetailMainImageFrame()
                    ProgressView(label: {
                        Text("Processing image...")
                    })
                    .progressViewStyle(.circular)
                    .labelStyle(.iconOnly)
                }
                
            case .result(_, let image, let confidence, let boundingBox):
                VStack {
                    image
                        .userDetailMainImageFrame()
                    
                    if let confidence = confidence {
                        Text("Confidence: \(String(format: "%.2f%%", confidence * 100))")
                    } else {
                        Text("No face detected")
                    }
                    
                    if let boundingBox = boundingBox {
                        Text("Bounding Box: \(boundingBox)")
                    }
                    
                    Button("Process Again") {
                        Task {
                            await onProcess()
                        }
                    }
                }
                
            case .error(let error):
                VStack {
                    ErrorView(error: error)
                    Button("Retry") {
                        Task {
                            await onProcess()
                        }
                    }
                }
            }
        }
    }
}

private extension Image {
    func userDetailMainImageFrame() -> some View {
        return resizable()
            .scaledToFill()
            .frame(width: 500, height: 500).padding()
    }
}

#Preview("Loading") {
    UserDetailStateView(
        state: .loading(user: .testUser1),
        onProcess: {},
        onImageLoaded: { _ in }
    )
}

#Preview("Loaded") {
    UserDetailStateView(
        state: .loaded(user: .testUser1, image: Image(systemName: "person")),
        onProcess: {},
        onImageLoaded: { _ in }
    )
}

#Preview("Processing") {
    UserDetailStateView(
        state: .processing(user: .testUser1, image: Image(systemName: "person")),
        onProcess: {},
        onImageLoaded: { _ in }
    )
}

#Preview("Result") {
    UserDetailStateView(
        state: .result(
            user: .testUser1,
            image: Image(systemName: "person"),
            confidence: 0.95,
            boundingBox: CGRect(x: 0, y: 0, width: 100, height: 100)
        ),
        onProcess: {},
        onImageLoaded: { _ in }
    )
}

#Preview("Error") {
    UserDetailStateView(
        state: .error(errr: NSError(
            domain: "com.toyapp",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to process image"]
        )),
        onProcess: {},
        onImageLoaded: { _ in }
    )
}
