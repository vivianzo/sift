import SwiftUI

/// Temporary grid that shows every loaded photo. Replaced by the Moments list.
struct RecentPhotosGrid: View {
  let photos: [PhotoMeta]

  private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 4)

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 2) {
        ForEach(photos) { photo in
          Thumbnail(id: photo.id)
        }
      }
    }
  }
}

private struct Thumbnail: View {
  let id: String

  @Environment(PhotoLibrary.self) private var library
  @Environment(\.displayScale) private var displayScale
  @State private var image: UIImage?

  var body: some View {
    Rectangle()
      .fill(.paper)
      .aspectRatio(1, contentMode: .fit)
      .overlay {
        if let image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        }
      }
      .clipped()
      .task(id: id) {
        let side = 120 * displayScale
        for await image in library.thumbnails(for: id, size: CGSize(width: side, height: side)) {
          self.image = image
        }
      }
  }
}
