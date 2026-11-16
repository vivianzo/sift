import SwiftUI

/// A moment in the Moments list: a photo collage, its name, when it was, and how many photos.
struct MomentCard: View {
  let moment: Moment
  let name: String

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      collage
        .frame(height: 176)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))

      VStack(alignment: .leading, spacing: 6) {
        Text(name)
          .font(.heading)
          .foregroundStyle(.ink)
          .multilineTextAlignment(.leading)
        Text(moment.dateText().uppercased())
          .font(.mono)
          .foregroundStyle(.muted)
        Text(moment.photos.count == 1 ? "1 photo" : "\(moment.photos.count) photos")
          .font(.note)
          .foregroundStyle(.muted)
      }
      .padding(.horizontal, 8)
      .padding(.top, 12)
      .padding(.bottom, 8)
    }
    .padding(6)
    .background(.paper, in: RoundedRectangle(cornerRadius: Radius.large))
    .overlay(RoundedRectangle(cornerRadius: Radius.large).stroke(.hairline))
    .accessibilityElement(children: .combine)
  }

  /// One big photo on the left and up to two stacked on the right, like the prototype.
  @ViewBuilder private var collage: some View {
    let photos = moment.coverPhotos
    HStack(spacing: 3) {
      PhotoThumbnail(id: photos[0].id, side: 240)
      if photos.count > 1 {
        VStack(spacing: 3) {
          ForEach(photos.dropFirst()) { photo in
            PhotoThumbnail(id: photo.id, side: 120)
          }
        }
        .frame(maxWidth: 120)
      }
    }
  }
}
