import SwiftUI

struct MomentsView: View {
    var body: some View {
        NavigationStack {
            StatusView(.empty(
                title: "No moments yet",
                systemImage: "photo.on.rectangle.angled",
                message: "Photos you take will be grouped here by time and place."
            ))
            .navigationTitle("Moments")
        }
    }
}

#Preview {
    MomentsView()
}
