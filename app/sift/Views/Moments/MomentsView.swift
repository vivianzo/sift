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
        list
      }
    }
    .toolbar(.hidden, for: .navigationBar)
    .navigationDestination(for: Moment.ID.self) { id in
      if let moment = library.moments.first(where: { $0.id == id }) {
        MomentDetailView(moment: moment, name: names.name(for: moment))
      }
    }
  }

  private var list: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        header
        LazyVStack(spacing: 20) {
          ForEach(library.moments.reversed()) { moment in
            NavigationLink(value: moment.id) {
              MomentCard(moment: moment, name: names.name(for: moment))
            }
            .buttonStyle(.plain)
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    // With the navigation bar hidden, nothing sits behind the status bar. This fills it with
    // the background so scrolled cards don't run under the clock.
    .safeAreaInset(edge: .top, spacing: 0) {
      Color.clear.frame(height: 0).background(.canvas)
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("SIFT")
        .font(.mono)
        .tracking(2)
        .foregroundStyle(.highlight)
      Text("Moments")
        .font(.displayLarge)
        .foregroundStyle(.ink)
      Text(
        library.moments.count == 1
          ? "1 moment from the last 30 days" : "\(library.moments.count) moments from the last 30 days"
      )
      .font(.note)
      .foregroundStyle(.muted)
    }
    .padding(.top, 12)
  }
}

#Preview {
  NavigationStack {
    MomentsView()
  }
  .environment(PhotoLibrary())
  .environment(MomentNames())
}
