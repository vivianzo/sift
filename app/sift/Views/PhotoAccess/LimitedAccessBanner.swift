import SwiftUI

/// Shown at the bottom of Moments when the user picked "Limited Access".
struct LimitedAccessBanner: View {
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "photo.badge.exclamationmark")
        .foregroundStyle(.highlight)
      Text("Sift can only see the photos you selected.")
        .font(.note)
        .foregroundStyle(.muted)
        .frame(maxWidth: .infinity, alignment: .leading)
      if let url = PhotoAccess.settingsURL {
        Link("Allow all", destination: url)
          .font(.label)
      }
    }
    .padding(12)
    .background(.paper, in: RoundedRectangle(cornerRadius: Radius.large))
    .overlay(RoundedRectangle(cornerRadius: Radius.large).stroke(.hairline))
    .padding(.horizontal, 16)
    .padding(.bottom, 8)
  }
}

#Preview {
  LimitedAccessBanner()
    .frame(maxHeight: .infinity, alignment: .bottom)
    .background(.canvas)
}
