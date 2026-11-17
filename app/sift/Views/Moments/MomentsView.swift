import SwiftUI

struct MomentsView: View {
  @Environment(PhotoLibrary.self) private var library
  @Environment(MomentNames.self) private var names

  var body: some View {
    Group {
      if library.moments.isEmpty {
        StatusView(
          .message(
            title: "No moments yet",
            systemImage: "photo.on.rectangle.angled",
            message: "Photos you take will be grouped here by time and place."
          )
        )
      } else {
        momentCards
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .navigationDestination(for: Moment.ID.self) { id in
      if let moment = library.moments.first(where: { $0.id == id }) {
        MomentDetailView(moment: moment, name: names.name(for: moment))
      }
    }
  }

  private var momentCards: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Spacing.xl) {
        ScreenHeader(eyebrow: "Sift", title: "Moments", subtitle: subtitle)
          .padding(.top, Spacing.md)
        LazyVStack(spacing: Spacing.xl) {
          ForEach(library.moments.reversed()) { moment in
            NavigationLink(value: moment.id) {
              MomentCard(moment: moment, name: names.name(for: moment))
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding(.horizontal, Spacing.xl)
      .padding(.bottom, Spacing.xxl)
    }
    // With the navigation bar hidden, nothing sits behind the status bar. This fills it with
    // the background so scrolled cards don't run under the clock.
    .safeAreaInset(edge: .top, spacing: 0) {
      Color.clear.frame(height: 0).background(.canvas)
    }
  }

  private var subtitle: String {
    "\(String.counted(library.moments.count, "moment")) from the last 30 days"
  }
}

#Preview {
  NavigationStack {
    MomentsView()
  }
  .environment(PhotoLibrary())
  .environment(MomentNames())
  .environment(PhotoStacks(library: PhotoLibrary()))
}
