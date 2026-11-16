import SwiftUI

/// A paper surface with a hairline border, for anything that sits on the canvas as its own object.
struct Card<Content: View>: View {
  let padding: CGFloat
  let content: Content

  init(padding: CGFloat = Spacing.xs, @ViewBuilder content: () -> Content) {
    self.padding = padding
    self.content = content()
  }

  var body: some View {
    content
      .padding(padding)
      .background(.paper, in: RoundedRectangle(cornerRadius: Radius.large))
      .overlay(RoundedRectangle(cornerRadius: Radius.large).stroke(.hairline))
  }
}

#Preview {
  VStack(spacing: Spacing.lg) {
    Card {
      Text("Default padding").font(.bodyText).frame(maxWidth: .infinity, alignment: .leading)
    }
    Card(padding: Spacing.lg) {
      Text("More padding").font(.bodyText).frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  .padding(Spacing.xl)
  .background(.canvas)
}
