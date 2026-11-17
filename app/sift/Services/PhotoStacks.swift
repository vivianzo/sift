import Observation
import Vision

/// Each moment's photos sorted into stacks of near-duplicates, found with Vision on the device.
@Observable
final class PhotoStacks {
  enum Progress {
    case finding(checked: Int, of: Int)
    case found([Stack])
  }

  private(set) var progress: [Moment.ID: Progress] = [:]

  /// Feature prints by photo ID, kept for the app's lifetime so reloads only look at new photos.
  /// Photos Vision couldn't read have no entry.
  @ObservationIgnored private var featurePrints: [String: FeaturePrintObservation] = [:]
  private let library: PhotoLibrary

  init(library: PhotoLibrary) {
    self.library = library
  }

  /// The moment's stacks, or nil while they're still being found.
  func stacks(for moment: Moment) -> [Stack]? {
    guard case .found(let stacks)? = progress[moment.id] else { return nil }
    return stacks
  }

  /// Finds stacks for each moment in turn, skipping ones that are done or already in progress.
  func find(in moments: [Moment]) async {
    for moment in moments {
      guard !Task.isCancelled else { return }
      switch progress[moment.id] {
      case .finding?:
        continue
      case .found(let stacks)? where Set(stacks.flatMap(\.photos).map(\.id)) == Set(moment.photos.map(\.id)):
        continue
      default:
        await find(in: moment)
      }
    }
  }

  private func find(in moment: Moment) async {
    for (index, photo) in moment.photos.enumerated() {
      progress[moment.id] = .finding(checked: index, of: moment.photos.count)
      guard featurePrints[photo.id] == nil, let image = await library.analysisImage(for: photo.id) else { continue }
      featurePrints[photo.id] = await Self.featurePrint(of: image)
    }
    let stacks = Stack.group(moment.photos) { a, b in
      guard let printA = featurePrints[a.id], let printB = featurePrints[b.id] else { return nil }
      return try? printA.distance(to: printB)
    }
    progress[moment.id] = .found(stacks)
  }

  /// Runs Vision off the main thread.
  @concurrent private static func featurePrint(of image: CGImage) async -> FeaturePrintObservation? {
    try? await GenerateImageFeaturePrintRequest().perform(on: image)
  }
}
