import Foundation
import Testing

@testable import sift

struct StackGroupingTests {
  /// Nov 1 2026, 8:00 PM in Boston.
  private let start = Date(timeIntervalSince1970: 1_793_581_200)

  /// A photo taken `seconds` after `start`. Photos with the same `look` are near-duplicates.
  private func photo(_ id: String, seconds: Double, look: Double) -> (PhotoMeta, Double) {
    (PhotoMeta(id: id, date: start.addingTimeInterval(seconds), location: nil), look)
  }

  /// Groups photos, measuring distance as the difference between their looks.
  private func stacks(_ photos: [(PhotoMeta, Double)]) -> [[String]] {
    let looks = Dictionary(uniqueKeysWithValues: photos.map { ($0.0.id, $0.1) })
    return Stack.group(photos.map(\.0)) { a, b in abs(looks[a.id]! - looks[b.id]!) }
      .map { $0.photos.map(\.id) }
  }

  @Test func noPhotosMeansNoStacks() {
    #expect(Stack.group([]) { _, _ in 0 }.isEmpty)
  }

  @Test func burstIsOneStack() {
    let burst = (0..<5).map { photo("b\($0)", seconds: Double($0) * 2, look: 0) }
    #expect(stacks(burst) == [["b0", "b1", "b2", "b3", "b4"]])
  }

  @Test func photosThatMatchNothingAreStacksOfOne() {
    let walk = (0..<3).map { photo("w\($0)", seconds: Double($0) * 10, look: Double($0)) }
    #expect(stacks(walk) == [["w0"], ["w1"], ["w2"]])
  }

  @Test func blurryShotStaysWithItsBurst() {
    let photos = [
      photo("sharp1", seconds: 0, look: 0),
      photo("blurry", seconds: 2, look: Stack.maxDistance - 0.01),
      photo("sharp2", seconds: 4, look: 0.02),
    ]
    #expect(stacks(photos) == [["sharp1", "blurry", "sharp2"]])
  }

  @Test func lookAlikesFarApartInTimeDontStack() {
    let photos = [photo("a", seconds: 0, look: 0), photo("b", seconds: Stack.maxGap + 1, look: 0)]
    #expect(stacks(photos) == [["a"], ["b"]])
  }

  @Test func gapIsMeasuredFromTheStacksLastPhoto() {
    // Each shot is within the gap of the one before, so a long, steady burst stays together.
    let burst = (0..<4).map { photo("b\($0)", seconds: Double($0) * (Stack.maxGap - 5), look: 0) }
    #expect(stacks(burst) == [["b0", "b1", "b2", "b3"]])
  }

  @Test func interleavedSubjectsMakeTwoStacks() {
    // Shooting the stage, turning to a friend, then back to the stage.
    let photos = [
      photo("stage1", seconds: 0, look: 0),
      photo("friend1", seconds: 3, look: 5),
      photo("stage2", seconds: 6, look: 0.1),
      photo("friend2", seconds: 9, look: 5.1),
    ]
    #expect(stacks(photos) == [["stage1", "stage2"], ["friend1", "friend2"]])
  }

  @Test func photoJoinsTheStackItLooksMostLike() {
    // "a" and "b" are too different to stack. "c" is close enough to both, but closer to "a".
    let photos = [
      photo("a", seconds: 0, look: 0),
      photo("b", seconds: 1, look: 0.9),
      photo("c", seconds: 2, look: 0.42),
    ]
    #expect(stacks(photos) == [["a", "c"], ["b"]])
  }

  @Test func photosVisionCouldntReadStayAlone() {
    let photos = (0..<3).map { PhotoMeta(id: "p\($0)", date: start.addingTimeInterval(Double($0)), location: nil) }
    let result = Stack.group(photos) { a, b in a.id == "p1" || b.id == "p1" ? nil : 0 }
    #expect(result.map { $0.photos.map(\.id) } == [["p0", "p2"], ["p1"]])
  }
}
