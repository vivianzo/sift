import Photos
import Testing

@testable import sift

struct PhotoLibraryAccessTests {
  @Test func onlyAuthorizedAndLimitedCanReadPhotos() {
    let all: [PHAuthorizationStatus] = [.notDetermined, .restricted, .denied, .authorized, .limited]
    #expect(all.filter(\.canReadPhotos) == [.authorized, .limited])
  }
}
