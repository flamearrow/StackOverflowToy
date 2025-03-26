# StackOverflow Toy App

A SwiftUI application that demonstrates modern iOS development practices by fetching and displaying Stack Overflow users. The app features face detection capabilities and follows MVVM architecture with clean separation of concerns.

## Instructions to Run

1. Clone the repository:
```bash
git clone https://github.com/flamearrow/StackOverflowToy.git
```

2. Open the project in Xcode 15.0 or later(developed in 16.2, tested on a physical iPhone 14 Pro/iOS 18.3.1 and an emulator iPhone 16 Pro/iOS 18.2)

3. Build and run the project (⌘R) or use the Play button in Xcode
  * Click the Load Top Users to fetch the first 10 users
  * scroll to bottom will automatically fetching the next 10 users
  * select a user from the list to enter `UserDetail` page
  * Click "Detect Face" to run facedetector, a bounding box will be drawn if a face is found

4. Run unit tests by hold clicking the Play button and select Test

## Dependencies

- **SwiftUI**: Modern declarative UI framework(didn't use UIKit, but can support it with `UIViewControllerRepresentable`)
- **Combine**: Reactive programming framework
- **Moya**: Better network tool on top of Alamofire with Compile-time API endpoint checking, used to fetch data from Stack Overflow API
- **Vision**: Apple's framework for face detection(didn't use extra model so `CoreML` is not used)
- **OSLog**: Apple's unified logging system
- **Concurrency**: Apple's structured concurrency with `Task`, Grand Central Dispatch is not used

## Architecture Design

The app follows MVVM (Model-View-ViewModel) architecture with the following key components. Each ViewModel exposes a corresponding ViewState to control what's displaying on View, handling success/failure cases. Please refer to the #Preview on each View file for each state.

The app also uses SwiftUI's `environmentObject` to provide dependency injection. Specifically, a singleton instance of `TopUserFetcher` and `FaceDetector` are injected through `GlobalDependencies` and used in ViewModels. Their mocks are provided for ViewModel's unit tests

`FaceDetector` is implemented with a singleton `VNSequenceRequestHandler` that's able to handle multiple `VNDetectFaceRectanglesRequest`s, it's shared across multiple inferencing tasks. The inference is performed off of `MainActor` to prevent freezing UI.

### Models
- `User`: Represents a Stack Overflow user
- `UserResponse`: API response model for user data

### Views
- `UserList`: Main view displaying a list of Stack Overflow users
- `UserDetail`: Detail view showing user information and face detection results

### ViewModels
- `UserListViewModel`: Manages user list state and data fetching
- `UserDetailViewModel`: Handles user detail state and face detection logic

### ML/Network
- `TopUserFetcher`: Protocol and implementation for fetching users from StackOverflow API
- `FaceDetector`: Protocol and implementation for performing face detection task on an image

## Testing
All business logics are encapsulated in the `ViewModel`s, `UserDetailViewModelTest`s and `UserListViewModelTest`s test the two ViewModels with mock dependencies to control its behavior. (Note the tests are not exhaustive due to time constraint.)

Snapshot tests are also omiited for time's sake, currently all the screens are manually verified by checking the corresponding `#Preview`
                                
## What's Next
1. **Better test coverage**
   - Add all cases to mock network error, timeout, success for UserDetailViewModelTests and UserListViewModelTests
   - Mock MayaProvider and add unit test TopUserFetcher, this is particularly useful should we need more features in TopUserFetcher, e.g (sort by badge count instead of reputation)
   - Add proper snapshot tests
   - Add proper UITest to for screen transitions

2. **Better network layer**
   - Currently the api invocation is not authorized and has limited quota(You can filter "userListViewModel" category in logging console to see remaining quota for each users fetch), also the response has a "backoff" field to wait when throttled. TopUserFetcher doesn't implement wait mechanisom when backoff is visible, nor does it provide OAuth token for a higher quota. We should request an [authenticated](https://api.stackexchange.com/docs/authentication) app key for higher quota limit.

3. **Data layer**
   - There's no persistance for user list now, and since the facedetector could run on device, we should persist the list and images to support offline capability
   - The User model can be saved in SwiftData or CoreData
   - Build in-memory LRU and/or on-disk cache for AsyncImage, or use a 3rd party library

4. **Better ML**
   - Expand the `FaceDetector` for more features(e.g `VNDetectFaceLandmarksRequest`) on top of current face bounding box detection
   - Support real-time detection with AVCaptureSession
