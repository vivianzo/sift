import SwiftUI

struct Banner: View {
  let systemImage: String
  let message: String
  var button: (title: String, action: () -> Void)? = nil

  var body: some View {
    Card(padding: Spacing.md) {
      HStack(spacing: Spacing.md) {
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
    }
  }
}

#Preview {
  VStack(spacing: Spacing.md) {
    Banner(systemImage: "info.circle", message: "A banner with only a message.")
    Banner(
      systemImage: "photo.badge.exclamationmark",
      message: "Sift can only see the photos you selected.",
      button: ("Allow all", {})
    )
  }
  .padding(Spacing.lg)
  .background(.canvas)
}
