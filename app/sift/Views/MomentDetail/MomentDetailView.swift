import SwiftUI

/// One moment's photos, sorted into stacks. Empty until stacks exist.
struct MomentDetailView: View {
  let moment: Moment
  let name: String

  var body: some View {
    StatusView(
      .message(
        title: "No stacks yet",
        systemImage: "square.stack",
        message:
          "\(String.counted(moment.photos.count, "photo")) from \(moment.dateText). Stacks of similar shots will show up here."
      )
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.canvas)
    .navigationTitle(name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(name).font(.heading).foregroundStyle(.ink)
      }
    }
  }
}

#Preview {
  NavigationStack {
    MomentDetailView(moment: .preview, name: "TD Garden, Boston")
  }
}
