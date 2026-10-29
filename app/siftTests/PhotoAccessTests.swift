import Photos
import Testing

@testable import sift

struct PhotoAccessTests {
  @Test(arguments: [
    (PHAuthorizationStatus.authorized, PhotoAccess.full),
    (.limited, .limited),
    (.denied, .denied),
    (.restricted, .restricted),
    (.notDetermined, .notDetermined),
  ])
  func mapsSystemStatus(status: PHAuthorizationStatus, expected: PhotoAccess) {
    #expect(PhotoAccess(status) == expected)
  }

  @Test func onlyFullAndLimitedCanReadPhotos() {
    let readable = [PhotoAccess.notDetermined, .full, .limited, .denied, .restricted].filter(\.canReadPhotos)
    #expect(readable == [.full, .limited])
  }
}
