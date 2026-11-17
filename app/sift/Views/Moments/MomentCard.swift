import SwiftUI

/// A moment in the Moments list: a photo collage, its name, when it was, and how many photos.
struct MomentCard: View {
  let moment: Moment
  let name: String

  @Environment(PhotoStacks.self) private var stacks

  private let collageHeight: CGFloat = 176
  private let sideColumnWidth: CGFloat = 120

  var body: some View {
    Card {
      VStack(alignment: .leading, spacing: 0) {
        collage
          .frame(height: collageHeight)
          .clipShape(RoundedRectangle(cornerRadius: Radius.medium))

        VStack(alignment: .leading, spacing: Spacing.xs) {
          Text(name)
            .font(.heading)
            .foregroundStyle(.ink)
            .multilineTextAlignment(.leading)
          Text(moment.dateText.uppercased())
            .font(.mono)
            .foregroundStyle(.muted)
          Text(photoCount)
            .font(.note)
            .foregroundStyle(.muted)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
      }
    }
    .accessibilityElement(children: .combine)
  }

  private var photoCount: String {
    .counted(moment.photos.count, "photo")
  }

  /// One big photo on the left and up to two stacked on the right, like the prototype.
  @ViewBuilder private var collage: some View {
    let photos = moment.coverPhotos(from: stacks.stacks(for: moment))
    HStack(spacing: Spacing.xxs) {
      PhotoThumbnail(id: photos[0].id, side: collageHeight * 1.4)
      if photos.count > 1 {
        VStack(spacing: Spacing.xxs) {
          ForEach(photos.dropFirst()) { photo in
            PhotoThumbnail(id: photo.id, side: sideColumnWidth)
          }
        }
        .frame(maxWidth: sideColumnWidth)
      }
    }
  }
}

#Preview {
  MomentCard(moment: .preview, name: "TD Garden, Boston")
    .padding(Spacing.xl)
    .background(.canvas)
    .environment(PhotoLibrary())
    .environment(PhotoStacks(library: PhotoLibrary()))
}
