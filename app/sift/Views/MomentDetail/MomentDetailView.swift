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
        message: "\(moment.photos.count) photos from \(moment.dateText()). Stacks of similar shots will show up here."
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
