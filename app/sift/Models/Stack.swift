import Foundation

/// Shots of the same thing taken moments apart, like a burst at a concert. A photo that looks
/// like nothing near it is a stack of one.
nonisolated struct Stack: Identifiable, Sendable {
  let id: String
  /// Oldest first.
  let photos: [PhotoMeta]

  /// Returns nil for an empty list, so every stack has at least one photo.
  init?(photos: [PhotoMeta]) {
    let sorted = photos.sorted { $0.date < $1.date }
    guard let first = sorted.first else { return nil }
    self.id = first.id
    self.photos = sorted
  }
}

extension Stack {
  /// A photo can join a stack only if it was taken within this long of the stack's last photo.
  static let maxGap: TimeInterval = 60
  /// Vision feature print distance under which two photos look alike. Sharp shots of one burst
  /// measure under 0.15 and a blurry shot against a sharp one up to about 0.5.
  static let maxDistance: Double = 0.5

  /// Groups a moment's photos into stacks, oldest first. Each photo joins the open stack (one whose
  /// last photo is within `maxGap`) holding the photo it looks most like, if that's under
  /// `maxDistance`. Otherwise it starts a new stack. `distance` returns nil when it can't compare
  /// two photos, and such photos don't stack.
  static func group(_ photos: [PhotoMeta], distance: (PhotoMeta, PhotoMeta) -> Double?) -> [Stack] {
    var groups: [[PhotoMeta]] = []
    for photo in photos.sorted(by: { $0.date < $1.date }) {
      let closest = groups.indices
        .filter { photo.date.timeIntervalSince(groups[$0].last!.date) <= maxGap }
        .compactMap { index in
          groups[index].compactMap { distance(photo, $0) }.min().map { (index, $0) }
        }
        .min { $0.1 < $1.1 }
      if let (index, nearest) = closest, nearest <= maxDistance {
        groups[index].append(photo)
      } else {
        groups.append([photo])
      }
    }
    return groups.compactMap(Stack.init)
  }
}
