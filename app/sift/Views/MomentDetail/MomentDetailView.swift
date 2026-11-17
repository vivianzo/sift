import SwiftUI

/// One moment's photos, sorted into stacks of similar shots, one row per stack.
struct MomentDetailView: View {
  let moment: Moment
  let name: String

  @Environment(PhotoStacks.self) private var photoStacks

  private let thumbnailSide: CGFloat = 96

  var body: some View {
    Group {
      switch photoStacks.progress[moment.id] {
      case .found(let stacks)?:
        stackRows(stacks)
      case .finding(let checked, let total)?:
        StatusView(
          .loading(message: "Finding similar shots, \(checked) of \(total)", progress: Double(checked) / Double(total)))
      case nil:
        StatusView(.loading(message: "Finding similar shots"))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.canvas)
    .navigationTitle(name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(name).font(.heading).foregroundStyle(.ink)
      }
    }
    .task(id: moment.id) {
      await photoStacks.find(in: [moment])
    }
  }

  private func stackRows(_ stacks: [Stack]) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Spacing.lg) {
        Text("\(String.counted(moment.photos.count, "photo")) in \(String.counted(stacks.count, "stack"))")
          .font(.mono)
          .foregroundStyle(.muted)
        LazyVStack(spacing: Spacing.md) {
          ForEach(stacks) { stack in
            Card {
              VStack(alignment: .leading, spacing: Spacing.xs) {
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: Spacing.xxs) {
                    ForEach(stack.photos) { photo in
                      PhotoThumbnail(id: photo.id, side: thumbnailSide)
                        .frame(width: thumbnailSide, height: thumbnailSide)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                    }
                  }
                }
                Text(String.counted(stack.photos.count, "shot"))
                  .font(.note)
                  .foregroundStyle(.muted)
                  .padding(.horizontal, Spacing.xxs)
              }
            }
          }
        }
      }
      .padding(.horizontal, Spacing.xl)
      .padding(.vertical, Spacing.md)
    }
  }
}

#Preview {
  // Previews have no photo library, so every photo ends up in a stack of its own.
  let library = PhotoLibrary()
  NavigationStack {
    MomentDetailView(moment: .preview, name: "TD Garden, Boston")
  }
  .environment(library)
  .environment(PhotoStacks(library: library))
}
