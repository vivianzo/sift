import CoreLocation
import Foundation
import Testing

@testable import sift

struct MomentGroupingTests {
  private let tdGarden = CLLocation(latitude: 42.3662, longitude: -71.0621)
  private let bostonCommon = CLLocation(latitude: 42.3550, longitude: -71.0656)
  private let fenway = CLLocation(latitude: 42.3467, longitude: -71.0972)
  private let harvardSquare = CLLocation(latitude: 42.3736, longitude: -71.1190)
  private let alfama = CLLocation(latitude: 38.7114, longitude: -9.1300)

  /// Nov 1 2026, 8:00 PM in Boston (EST, after daylight saving ends that morning).
  private let start = Date(timeIntervalSince1970: 1_793_581_200)

  /// A photo taken `minutes` after `start`.
  private func photo(_ id: String, minutes: Double, at location: CLLocation?) -> PhotoMeta {
    PhotoMeta(id: id, date: start.addingTimeInterval(minutes * 60), location: location)
  }

  private func ids(_ moments: [Moment]) -> [[String]] {
    moments.map { $0.photos.map(\.id) }
  }

  @Test func noPhotosMeansNoMoments() {
    #expect(Moment.group([]).isEmpty)
  }

  @Test func concertIsOneMoment() {
    // Every 10 minutes for 3 hours at the same place.
    let photos = (0...18).map { photo("c\($0)", minutes: Double($0) * 10, at: tdGarden) }
    let moments = Moment.group(photos)
    #expect(moments.count == 1)
    #expect(moments[0].photos.count == 19)
  }

  @Test func overnightGapSplitsTripDays() {
    let day1 = (0..<5).map { photo("d1-\($0)", minutes: Double($0) * 60, at: alfama) }
    let day2 = (0..<5).map { photo("d2-\($0)", minutes: 24 * 60 + Double($0) * 60, at: alfama) }
    #expect(ids(Moment.group(day1 + day2)) == [day1.map(\.id), day2.map(\.id)])
  }

  @Test func gapJustUnderTheLimitStaysOneMoment() {
    let photos = [photo("a", minutes: 0, at: bostonCommon), photo("b", minutes: 85, at: bostonCommon)]
    #expect(ids(Moment.group(photos)) == [["a", "b"]])
  }

  @Test func gapJustOverTheLimitStartsANewMoment() {
    let photos = [photo("a", minutes: 0, at: bostonCommon), photo("b", minutes: 95, at: bostonCommon)]
    #expect(ids(Moment.group(photos)) == [["a"], ["b"]])
  }

  @Test func movingFarStartsANewMomentEvenSoonAfter() {
    // Fenway to Harvard Square is about 3.5 km.
    let photos = [photo("fenway", minutes: 0, at: fenway), photo("harvard", minutes: 10, at: harvardSquare)]
    #expect(ids(Moment.group(photos)) == [["fenway"], ["harvard"]])
  }

  @Test func slowWalkStaysOneMoment() {
    // Each photo is about 600 m past the last, so the walk covers ~3 km but never jumps 1 km.
    let photos = (0..<6).map { i in
      photo("w\(i)", minutes: Double(i) * 5, at: CLLocation(latitude: 42.35 + Double(i) * 0.0054, longitude: -71.06))
    }
    #expect(Moment.group(photos).count == 1)
  }

  @Test func photoWithoutLocationJoinsByTime() {
    let photos = [
      photo("a", minutes: 0, at: tdGarden),
      photo("no-location", minutes: 30, at: nil),
      photo("b", minutes: 60, at: tdGarden),
    ]
    #expect(ids(Moment.group(photos)) == [["a", "no-location", "b"]])
  }

  @Test func distanceIsMeasuredFromTheLastPhotoWithALocation() {
    // The no-location photo in between doesn't hide the jump from Fenway to Harvard Square.
    let photos = [
      photo("fenway", minutes: 0, at: fenway),
      photo("no-location", minutes: 5, at: nil),
      photo("harvard", minutes: 10, at: harvardSquare),
    ]
    #expect(ids(Moment.group(photos)) == [["fenway", "no-location"], ["harvard"]])
  }

  @Test func photosWithoutAnyLocationGroupByTime() {
    let photos = [
      photo("a", minutes: 0, at: nil),
      photo("b", minutes: 20, at: nil),
      photo("c", minutes: 200, at: nil),
    ]
    #expect(ids(Moment.group(photos)) == [["a", "b"], ["c"]])
  }

  @Test func crossingMidnightStaysOneMoment() {
    // 11:20 PM to 12:50 AM.
    let photos = (0...6).map { photo("s\($0)", minutes: 200 + Double($0) * 15, at: tdGarden) }
    #expect(Moment.group(photos).count == 1)
  }

  @Test func momentNeedsAtLeastOnePhoto() {
    #expect(Moment(photos: []) == nil)
  }

  @Test func momentSortsItsPhotos() throws {
    let moment = try #require(
      Moment(photos: [photo("late", minutes: 10, at: tdGarden), photo("early", minutes: 0, at: tdGarden)]))
    #expect(moment.photos.map(\.id) == ["early", "late"])
    #expect(moment.id == "early")
  }

  @Test func sortsPhotosOldestFirst() {
    let photos = [
      photo("late", minutes: 300, at: tdGarden),
      photo("early", minutes: 0, at: tdGarden),
      photo("middle", minutes: 10, at: tdGarden),
    ]
    let moments = Moment.group(photos)
    #expect(ids(moments) == [["early", "middle"], ["late"]])
    #expect(moments[0].start == photos[1].date)
    #expect(moments[0].end == photos[2].date)
  }
}
