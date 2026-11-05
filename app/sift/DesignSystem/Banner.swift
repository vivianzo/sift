import SwiftUI

struct Banner: View {
  let systemImage: String
  let message: String
  var button: (title: String, action: () -> Void)? = nil

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemImage)
        .foregroundStyle(.highlight)
      Text(message)
        .font(.note)
        .foregroundStyle(.muted)
        .frame(maxWidth: .infinity, alignment: .leading)
      if let button {
        Button(button.title, action: button.action)
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
      button: ("Allow all", {})
    )
  }
  .padding(16)
  .background(.canvas)
}
