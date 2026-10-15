import SwiftUI

/// Home list of auto-grouped moments. Placeholder until #7.
struct MomentsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No moments yet",
                systemImage: "photo.on.rectangle.angled",
                description: Text("Photos you take will be grouped here by time and place.")
            )
            .navigationTitle("Moments")
        }
    }
}

#Preview {
    MomentsView()
}
