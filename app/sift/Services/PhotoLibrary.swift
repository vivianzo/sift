import Observation
import Photos
import UIKit

/// Recent photos from the library and their thumbnails. Views read `photos` and ask for
/// thumbnails here instead of talking to PhotoKit themselves.
@Observable
final class PhotoLibrary {
  /// What views show and grouping uses. Each load replaces it.
  private(set) var photos: [PhotoMeta] = []
  /// `photos` grouped into moments, oldest first. Each load replaces it.
  private(set) var moments: [Moment] = []

  /// PhotoKit's handle for each photo, used only to request thumbnails. Views never read it,
  /// so changes to it don't redraw anything. Each load replaces it.
  private var assetsByID: [String: PHAsset] = [:]
  private let imageManager = PHCachingImageManager()

  /// Loads photos taken in the last `pastDays` days, newest first.
  func loadRecent(pastDays: Int = 30) {
    let earliestDate = Calendar.current.date(byAdding: .day, value: -pastDays, to: .now) ?? .now
    let options = PHFetchOptions()
    options.predicate = NSPredicate(
      format: "mediaType == %d AND creationDate >= %@",
      PHAssetMediaType.image.rawValue,
      earliestDate as NSDate
    )
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    let result = PHAsset.fetchAssets(with: options)
    let fetched = result.objects(at: IndexSet(integersIn: 0..<result.count))
    assetsByID = Dictionary(uniqueKeysWithValues: fetched.map { ($0.localIdentifier, $0) })
    photos = fetched.compactMap { asset in
      asset.creationDate.map { PhotoMeta(id: asset.localIdentifier, date: $0, location: asset.location) }
    }
    moments = Moment.group(photos)
  }

  /// Streams a fast, blurry thumbnail, then the sharp one. Images aren't stored here:
  /// `PHCachingImageManager` keeps its own cache and frees memory as needed.
  /// Cancelling the task that reads the stream, e.g. when a grid cell scrolls away, cancels the request.
  func thumbnails(for id: String, size: CGSize) -> AsyncStream<UIImage> {
    AsyncStream { continuation in
      guard let asset = assetsByID[id] else {
        continuation.finish()
        return
      }
      let options = PHImageRequestOptions()
      options.deliveryMode = .opportunistic
      options.resizeMode = .fast

      // Photos may call this off the main thread, so it must not be main-actor isolated.
      let request = imageManager.requestImage(
        for: asset,
        targetSize: size,
        contentMode: .aspectFill,
        options: options
      ) { @Sendable image, info in
        if let image {
          continuation.yield(image)
        }
        if (info?[PHImageResultIsDegradedKey] as? Bool) != true {
          continuation.finish()
        }
      }
      continuation.onTermination = { _ in
        Task { @MainActor [weak self] in
          self?.imageManager.cancelImageRequest(request)
        }
      }
    }
  }
}
