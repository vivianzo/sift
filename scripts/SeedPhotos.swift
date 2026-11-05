// Generates sample photos for the dev simulator. Run through scripts/seed-simulator.sh.
//
// Usage: swift SeedPhotos.swift <output-dir> [bulk-count]
//
// Each scenario is a moment the app should find: photos close in time and place,
// taken in bursts of near-identical shots a few seconds apart, with some blurry ones.
// Dates are relative to today so the moments always fall inside Sift's 30-day window
// (except "Summer picnic", which is meant to fall outside it).

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Scenario {
  let name: String
  let timeZone: String
  /// nil for photos without a location, like screenshots or location services turned off.
  let coordinate: (latitude: Double, longitude: Double)?
  let daysAgo: Int
  let start: (hour: Int, minute: Int)
  let minutes: Int
  let bursts: Int
  let hue: Double
}

let scenarios = [
  Scenario(
    name: "Concert at TD Garden", timeZone: "America/New_York", coordinate: (42.3662, -71.0621),
    daysAgo: 5, start: (20, 12), minutes: 172, bursts: 8, hue: 0.78),
  Scenario(
    name: "Brunch on Beacon Hill", timeZone: "America/New_York", coordinate: (42.3581, -71.0707),
    daysAgo: 3, start: (11, 20), minutes: 45, bursts: 5, hue: 0.09),
  Scenario(
    name: "Sunset at Revere Beach", timeZone: "America/New_York", coordinate: (42.4085, -70.9915),
    daysAgo: 9, start: (18, 31), minutes: 31, bursts: 4, hue: 0.03),
  Scenario(
    name: "Lisbon day 1", timeZone: "Europe/Lisbon", coordinate: (38.7107, -9.1366),
    daysAgo: 20, start: (10, 4), minutes: 540, bursts: 7, hue: 0.12),
  Scenario(
    name: "Lisbon day 2", timeZone: "Europe/Lisbon", coordinate: (38.7114, -9.1300),
    daysAgo: 19, start: (9, 40), minutes: 560, bursts: 7, hue: 0.55),
  Scenario(
    name: "Lisbon day 3", timeZone: "Europe/Lisbon", coordinate: (38.6916, -9.2160),
    daysAgo: 18, start: (10, 15), minutes: 480, bursts: 6, hue: 0.33),
  Scenario(
    name: "At home, no location", timeZone: "America/New_York", coordinate: nil,
    daysAgo: 1, start: (21, 0), minutes: 30, bursts: 3, hue: 0.65),
  Scenario(
    name: "Summer picnic (older than 30 days)", timeZone: "America/New_York", coordinate: (42.3550, -71.0656),
    daysAgo: 45, start: (13, 0), minutes: 60, bursts: 3, hue: 0.25),
]

/// Same seed, same sequence, so every run produces the same library.
struct SeededRandom {
  var state: UInt64
  mutating func next() -> Double {
    state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Double(state >> 11) / Double(1 << 53)
  }
}

let arguments = CommandLine.arguments
guard arguments.count >= 2 else {
  print("Usage: swift SeedPhotos.swift <output-dir> [bulk-count]")
  exit(1)
}
let outputDirectory = URL(fileURLWithPath: arguments[1])
let bulkCount = arguments.count > 2 ? Int(arguments[2]) ?? 0 : 0

let width = 1200
let height = 900
let colorSpace = CGColorSpaceCreateDeviceRGB()

func color(hue: Double, saturation: Double, brightness: Double) -> CGColor {
  let h = (hue - floor(hue)) * 6
  let f = h - floor(h)
  let p = brightness * (1 - saturation)
  let q = brightness * (1 - saturation * f)
  let t = brightness * (1 - saturation * (1 - f))
  let rgb = [
    (brightness, t, p), (q, brightness, p), (p, brightness, t), (p, q, brightness), (t, p, brightness),
    (brightness, p, q),
  ][Int(h) % 6]
  return CGColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
}

/// One burst shares a composition; each shot in it is shifted slightly, like a hand-held phone.
func drawShot(hue: Double, compositionSeed: UInt64, shift: CGFloat, blurry: Bool) -> CGImage {
  let context = CGContext(
    data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
    space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
  var random = SeededRandom(state: compositionSeed)
  let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
      color(hue: hue, saturation: 0.45, brightness: 0.95), color(hue: hue + 0.08, saturation: 0.8, brightness: 0.45),
    ] as CFArray,
    locations: [0, 1])!
  context.drawLinearGradient(
    gradient, start: CGPoint(x: shift, y: 0), end: CGPoint(x: CGFloat(width), y: CGFloat(height)), options: [])
  for _ in 0..<7 {
    let size = 80 + random.next() * 260
    let rect = CGRect(
      x: random.next() * Double(width) + shift, y: random.next() * Double(height) + shift / 2,
      width: size, height: size)
    context.setFillColor(
      color(hue: hue + random.next() * 0.3 - 0.15, saturation: 0.5, brightness: 1).copy(alpha: 0.55)!)
    random.next() > 0.5 ? context.fillEllipse(in: rect) : context.fill(rect)
  }
  let image = context.makeImage()!
  guard blurry else { return image }
  // Scale down and back up to fake motion blur.
  let small = CGContext(
    data: nil, width: width / 12, height: height / 12, bitsPerComponent: 8, bytesPerRow: 0,
    space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
  small.interpolationQuality = .high
  small.draw(image, in: CGRect(x: 0, y: 0, width: width / 12, height: height / 12))
  context.interpolationQuality = .high
  context.draw(small.makeImage()!, in: CGRect(x: 0, y: 0, width: width, height: height))
  return context.makeImage()!
}

func write(
  _ image: CGImage, named name: String, date: Date, timeZone: TimeZone,
  coordinate: (latitude: Double, longitude: Double)?
) {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = timeZone
  formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
  let offsetFormatter = DateFormatter()
  offsetFormatter.locale = Locale(identifier: "en_US_POSIX")
  offsetFormatter.timeZone = timeZone
  offsetFormatter.dateFormat = "xxx"

  var properties: [CFString: Any] = [
    kCGImagePropertyExifDictionary: [
      kCGImagePropertyExifDateTimeOriginal: formatter.string(from: date),
      kCGImagePropertyExifOffsetTimeOriginal: offsetFormatter.string(from: date),
    ],
    kCGImageDestinationLossyCompressionQuality: 0.7,
  ]
  if let coordinate {
    properties[kCGImagePropertyGPSDictionary] = [
      kCGImagePropertyGPSLatitude: abs(coordinate.latitude),
      kCGImagePropertyGPSLatitudeRef: coordinate.latitude >= 0 ? "N" : "S",
      kCGImagePropertyGPSLongitude: abs(coordinate.longitude),
      kCGImagePropertyGPSLongitudeRef: coordinate.longitude >= 0 ? "E" : "W",
    ]
  }
  let url = outputDirectory.appendingPathComponent(name) as CFURL
  let destination = CGImageDestinationCreateWithURL(url, UTType.jpeg.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, image, properties as CFDictionary)
  CGImageDestinationFinalize(destination)
}

var random = SeededRandom(state: 2026)
var total = 0
print("Moments the app should find:")
for (index, scenario) in scenarios.enumerated() {
  let timeZone = TimeZone(identifier: scenario.timeZone)!
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = timeZone
  let day = calendar.date(byAdding: .day, value: -scenario.daysAgo, to: calendar.startOfDay(for: .now))!
  let start = calendar.date(bySettingHour: scenario.start.hour, minute: scenario.start.minute, second: 0, of: day)!

  var shots = 0
  for burst in 0..<scenario.bursts {
    let burstStart = start.addingTimeInterval(Double(scenario.minutes * 60) * Double(burst) / Double(scenario.bursts))
    // Wander a little within the place (up to ~300 m) so locations aren't identical.
    let coordinate = scenario.coordinate.map {
      (latitude: $0.latitude + (random.next() - 0.5) * 0.005, longitude: $0.longitude + (random.next() - 0.5) * 0.005)
    }
    let burstSize = 1 + Int(random.next() * 5)
    let seed = UInt64(index * 1000 + burst + 1)
    for shot in 0..<burstSize {
      let date = burstStart.addingTimeInterval(Double(shot) * (1 + random.next() * 2))
      let blurry = burstSize > 2 && random.next() < 0.25
      let image = drawShot(hue: scenario.hue, compositionSeed: seed, shift: CGFloat(shot) * 14, blurry: blurry)
      let name = String(format: "seed-%02d-b%02d-s%d%@.jpg", index, burst, shot, blurry ? "-blurry" : "")
      write(image, named: name, date: date, timeZone: timeZone, coordinate: coordinate)
      shots += 1
    }
  }
  total += shots
  var style = Date.FormatStyle.dateTime.month(.abbreviated).day().hour().minute().timeZone()
  style.timeZone = timeZone
  print("  \(scenario.name): \(shots) photos in \(scenario.bursts) bursts, starting \(start.formatted(style))")
}

// Filler for scroll testing: one photo per minute from midnight 27 days ago, no location.
// That day has no scenario, so the filler doesn't merge into another moment.
let fillerStart = Calendar.current.date(byAdding: .day, value: -27, to: Calendar.current.startOfDay(for: .now))!
for i in 0..<bulkCount {
  let date = fillerStart.addingTimeInterval(Double(i) * 60)
  let image = drawShot(hue: Double(i % 360) / 360, compositionSeed: UInt64(100_000 + i), shift: 0, blurry: false)
  write(image, named: String(format: "bulk-%05d.jpg", i), date: date, timeZone: .current, coordinate: nil)
}
if bulkCount > 0 {
  print("  Plus \(bulkCount) filler photos, one a minute starting 27 days ago (no location).")
}
print("Wrote \(total + bulkCount) photos.")
