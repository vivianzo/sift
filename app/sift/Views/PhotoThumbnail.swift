import SwiftUI

/// A photo from the library, cropped to fill whatever frame it's given.
struct PhotoThumbnail: View {
  let id: String
  /// The longest side the thumbnail is shown at, in points. Used to request the right size.
  let side: CGFloat

  @Environment(PhotoLibrary.self) private var library
  @Environment(\.displayScale) private var displayScale
  @State private var image: UIImage?

  var body: some View {
    Rectangle()
      .fill(.hairline)
      .overlay {
        if let image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        }
      }
      .clipped()
      .task(id: id) {
        let pixels = side * displayScale
        for await image in library.thumbnails(for: id, size: CGSize(width: pixels, height: pixels)) {
          self.image = image
        }
      }
  }
}

#Preview("Placeholder while loading") {
  // Previews have no photo library, so this shows the placeholder a cell has before its image loads.
  PhotoThumbnail(id: "preview", side: 120)
    .frame(width: 120, height: 160)
    .padding(Spacing.xl)
    .background(.canvas)
    .environment(PhotoLibrary())
}
