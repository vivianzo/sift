import Observation
import Photos
import UIKit

/// Recent photos from the library and their thumbnails. Views read `photos` and ask for
/// thumbnails here instead of talking to PhotoKit themselves.
@Observable
final class PhotoLibrary {
  private(set) var photos: [PhotoMeta] = []

  @ObservationIgnored private var assets: [String: PHAsset] = [:]
  @ObservationIgnored private let imageManager = PHCachingImageManager()

  /// Loads photos taken in the last `days` days, newest first.
  func loadRecent(days: Int = 30) {
    let since = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    let options = PHFetchOptions()
    options.predicate = NSPredicate(
      format: "mediaType == %d AND creationDate >= %@",
      PHAssetMediaType.image.rawValue,
      since as NSDate
    )
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    let result = PHAsset.fetchAssets(with: options)
    let fetched = result.objects(at: IndexSet(integersIn: 0..<result.count))
    assets = Dictionary(uniqueKeysWithValues: fetched.map { ($0.localIdentifier, $0) })
    photos = fetched.compactMap { asset in
      asset.creationDate.map { PhotoMeta(id: asset.localIdentifier, date: $0, location: asset.location) }
    }
  }

  /// A fast, blurry thumbnail first, then the sharp one. Cancelling the task that reads
  /// the stream (e.g. a grid cell scrolling away) cancels the request.
  func thumbnails(for id: String, size: CGSize) -> AsyncStream<UIImage> {
    AsyncStream { continuation in
      guard let asset = assets[id] else {
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
