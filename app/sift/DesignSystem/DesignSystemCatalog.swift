import SwiftUI

/// Every color, text style, and radius on one screen, for checking the design system in previews.
private struct DesignSystemCatalog: View {
  private let colors: [(name: String, color: Color)] = [
    ("Canvas", .canvas),
    ("Paper", .paper),
    ("Ink", .ink),
    ("Muted", .muted),
    ("Hairline", .hairline),
    ("Highlight", .highlight),
    ("AccentColor", .accentColor),
  ]

  private let fonts: [(name: String, font: Font)] = [
    ("displayLarge", .displayLarge),
    ("display", .display),
    ("heading", .heading),
    ("headingItalic", .headingItalic),
    ("bodyText", .bodyText),
    ("bodyEmphasis", .bodyEmphasis),
    ("label", .label),
    ("note", .note),
    ("mono", .mono),
  ]

  private let radii: [(name: String, value: CGFloat)] = [
    ("small", Radius.small),
    ("medium", Radius.medium),
    ("large", Radius.large),
  ]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Spacing.xxxl) {
        section("Colors") {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: Spacing.md)], spacing: Spacing.md) {
            ForEach(colors, id: \.name) { item in
              VStack(alignment: .leading, spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: Radius.medium)
                  .fill(item.color)
                  .frame(height: 56)
                  .overlay(RoundedRectangle(cornerRadius: Radius.medium).stroke(.hairline))
                Text(item.name).font(.mono).foregroundStyle(.muted)
              }
            }
          }
        }

        section("Type") {
          VStack(alignment: .leading, spacing: Spacing.md) {
            ForEach(fonts, id: \.name) { item in
              VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Lorde at TD Garden").font(item.font)
                Text(item.name).font(.mono).foregroundStyle(.muted)
              }
            }
          }
        }

        section("Radius") {
          HStack(spacing: Spacing.lg) {
            ForEach(radii, id: \.name) { item in
              VStack(spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: item.value)
                  .fill(.paper)
                  .stroke(.hairline)
                  .frame(width: 72, height: 72)
                Text("\(item.name) · \(Int(item.value))").font(.mono).foregroundStyle(.muted)
              }
            }
          }
        }
      }
      .padding(Spacing.xl)
    }
    .background(.canvas)
    .foregroundStyle(.ink)
  }

  private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: Spacing.md) {
      Text(title).font(.heading)
      content()
    }
  }
}

#Preview("Light") {
  DesignSystemCatalog()
}

#Preview("Dark") {
  DesignSystemCatalog()
    .preferredColorScheme(.dark)
}
