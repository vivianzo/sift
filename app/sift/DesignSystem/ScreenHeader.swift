import SwiftUI

/// The big serif title at the top of a tab, with an optional label above and note below.
struct ScreenHeader: View {
  var eyebrow: String? = nil
  let title: String
  var subtitle: String? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing.xs) {
      if let eyebrow {
        Text(eyebrow.uppercased())
          .font(.mono)
          .tracking(2)
          .foregroundStyle(.highlight)
      }
      Text(title)
        .font(.displayLarge)
        .foregroundStyle(.ink)
      if let subtitle {
        Text(subtitle)
          .font(.note)
          .foregroundStyle(.muted)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  ScreenHeader(eyebrow: "Sift", title: "Moments", subtitle: "7 moments from the last 30 days")
    .padding(Spacing.xl)
    .background(.canvas)
}
