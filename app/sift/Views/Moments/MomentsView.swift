import SwiftUI

struct MomentsView: View {
  @Environment(PhotoLibrary.self) private var library

  var body: some View {
    Group {
      if library.photos.isEmpty {
        StatusView(
          .message(
            title: "No moments yet",
            systemImage: "photo.on.rectangle.angled",
            message: "Photos you take will be grouped here by time and place."
          )
        )
      } else {
        RecentPhotosGrid(photos: library.photos)
      }
    }
    .navigationTitle("Moments")
  }
}

#Preview {
  NavigationStack {
    MomentsView()
  }
  .environment(PhotoLibrary())
}
