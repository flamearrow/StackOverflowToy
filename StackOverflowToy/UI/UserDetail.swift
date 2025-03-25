//
//  UserDetail.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

struct UserDetail: View {
    @EnvironmentObject var globalDependencies: GlobalDependencies
    
    @State private var viewModel: UserDetailViewModel?
    
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            UserDetailStateView(
                state: viewModel?.viewState ?? .loading(user: user),
                onProcess: {
                    await viewModel?.processImage()
                },
                onImageLoaded: { image in
                    viewModel?.setImage(image)
                },
                onReset: { user in
                    viewModel?.reset(user: user)
                }
            )
        }
        .padding()
        .onAppear {
            viewModel = UserDetailViewModel(user: user, faceDetector: globalDependencies.faceDetector)
        }
    }
}

struct UserDetailStateView: View {
    let state: UserDetailViewState
    let onProcess: () async -> Void
    let onImageLoaded: (Image) async -> Void
    let onReset: (User) -> Void
    
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
                VStack(spacing: 20) {
                    image
                        .userDetailMainImageFrame()
                    
                    Button("Detect Face") {
                        Task {
                            await onProcess()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(icon: "face.smiling"))
                }
                
            case .processing(_, let image):
                VStack(spacing: 20) {
                    image
                        .userDetailMainImageFrame()
                    
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Processing image...")
                            .font(.headline)
                    }
                    .foregroundColor(.secondary)
                }
                
            case .result(let user, let image, let confidence, let boundingBox):
                VStack(spacing: 20) {
                    if let boundingBox = boundingBox, let confidence = confidence {
                        image.userDetailMainImageFrame()
                            .faceRectangleOverlay(boundingBox: boundingBox, confidence: confidence)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Face Detected!")
                                .font(.headline)
                            Text("(\(Int(confidence * 100))% confidence)")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        image.userDetailMainImageFrame()
                        
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("No face detected")
                                .font(.headline)
                        }
                    }
                    
                    Button("Detect Again") {
                        onReset(user)
                    }
                    .buttonStyle(PrimaryButtonStyle(icon: "arrow.clockwise"))
                }
                
            case .error(let user, let error):
                VStack(spacing: 20) {
                    ErrorView(error: error)
                    if let user = user {
                        Button("Try Again") {
                            onReset(user)
                        }
                        .buttonStyle(PrimaryButtonStyle(icon: "arrow.clockwise"))
                    }
                }
            }
        }
    }
}

// MARK: extensions
private extension Image {
    func userDetailMainImageFrame() -> some View {
        return resizable()
            .scaledToFit()
            .frame(width: UIConstants.mainImageSize, height: UIConstants.mainImageSize)
    }
}

private extension View {
    func faceRectangleOverlay(boundingBox: CGRect, confidence: Double) -> some View {
        return overlay(alignment: .bottomLeading) {
            Rectangle()
                .stroke(Color.confidenceColor(confidence), lineWidth: 3)
                .frame(
                    width: UIConstants.mainImageSize * boundingBox.width,
                    height: UIConstants.mainImageSize * boundingBox.height
                )
                .offset(
                    x: UIConstants.mainImageSize * boundingBox.minX,
                    y: -UIConstants.mainImageSize * boundingBox.minY
                )
        }
    }
}

private extension Color {
    static func confidenceColor(_ confidence: Double) -> Color {
        // Normalize confidence from 0.5-1.0 to 0-1
        let normalizedConfidence = (confidence - 0.5) * 2
        return Color(red: 1 - normalizedConfidence, green: normalizedConfidence, blue: 0)
    }
}

// MARK: UserDetailViewState
enum UserDetailViewState {
    case loading(user: User)
    case loaded(user: User, image: Image)
    case processing(user: User, image: Image)
    case result(user: User, image: Image, confidence: Double?, boundingBox: CGRect?)
    case error(user: User?, error: Error)
    
    func getUser() -> User? {
        switch self {
        case .loading(let user),
                .loaded(let user, _),
                .processing(let user, _),
                .result(let user, _, _, _):
            return user
        case .error(let user, _):
            return user
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

// MARK: Previews
#Preview("Loading") {
    UserDetailStateView(
        state: .loading(user: .testUser1),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}

#Preview("Loaded") {
    UserDetailStateView(
        state: .loaded(user: .testUser1, image: Image(systemName: "person")),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}

#Preview("Processing") {
    UserDetailStateView(
        state: .processing(user: .testUser1, image: Image(systemName: "person")),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}

#Preview("Result") {
    UserDetailStateView(
        state: .result(
            user: .testUser1,
            image: Image(systemName: "person"),
            confidence: 0.89,
            boundingBox: CGRect(x: 0.22, y: 0.27, width: 0.51, height: 0.52)
        ),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}


#Preview("Result - no face") {
    UserDetailStateView(
        state: .result(
            user: .testUser1,
            image: Image(systemName: "person"),
            confidence: nil,
            boundingBox: nil
        ),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}

#Preview("Error") {
    UserDetailStateView(
        state: .error(
            user: .testUser1,
            error: NSError(
                domain: "com.toyapp",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to process image"]
            )
        ),
        onProcess: {},
        onImageLoaded: { _ in },
        onReset: { _ in }
    )
}
