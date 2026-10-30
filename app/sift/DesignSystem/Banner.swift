import SwiftUI

/// A one-line notice with an optional button, e.g. "Sift can only see the photos you selected."
/// The caller decides where it goes and adds outer padding.
struct Banner: View {
  let systemImage: String
  let message: String
  var callToAction: CallToAction? = nil

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemImage)
        .foregroundStyle(.highlight)
      Text(message)
        .font(.note)
        .foregroundStyle(.muted)
        .frame(maxWidth: .infinity, alignment: .leading)
      if let callToAction {
        Button(callToAction.title, action: callToAction.perform)
          .font(.label)
      }
    }
    .padding(12)
    .background(.paper, in: RoundedRectangle(cornerRadius: Radius.large))
    .overlay(RoundedRectangle(cornerRadius: Radius.large).stroke(.hairline))
  }
}

#Preview {
  VStack(spacing: 12) {
    Banner(systemImage: "info.circle", message: "A banner with only a message.")
    Banner(
      systemImage: "photo.badge.exclamationmark",
      message: "Sift can only see the photos you selected.",
      callToAction: .init(title: "Allow all", perform: {})
    )
  }
  .padding(16)
  .background(.canvas)
}
