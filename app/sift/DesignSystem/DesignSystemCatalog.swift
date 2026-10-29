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
      VStack(alignment: .leading, spacing: 32) {
        section("Colors") {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 12)], spacing: 12) {
            ForEach(colors, id: \.name) { item in
              VStack(alignment: .leading, spacing: 6) {
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
          VStack(alignment: .leading, spacing: 14) {
            ForEach(fonts, id: \.name) { item in
              VStack(alignment: .leading, spacing: 2) {
                Text("Lorde at TD Garden").font(item.font)
                Text(item.name).font(.mono).foregroundStyle(.muted)
              }
            }
          }
        }

        section("Radius") {
          HStack(spacing: 16) {
            ForEach(radii, id: \.name) { item in
              VStack(spacing: 6) {
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
      .padding(20)
    }
    .background(.canvas)
    .foregroundStyle(.ink)
  }

  private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 14) {
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
