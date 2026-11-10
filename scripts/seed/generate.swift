// Generates sample photos from a seed file. Run through scripts/seed-simulator.sh.
//
// Usage:
//   swift generate.swift <seed.json> <output-dir> [bulk-count]
//   swift generate.swift --list <seeds-dir>
//
// A seed file lists scenarios. Each scenario is a group of photos close in time and place,
// taken in bursts of near-identical shots a few seconds apart, with some blurry ones.
// Dates are relative to today so the library always lands in the same spot of Sift's
// 30-day window. The same seed file always produces the same photos.

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Seed: Decodable {
  let description: String
  /// What the app should find, printed after generating. Useful when checking grouping.
  let expected: [String]
  let scenarios: [Scenario]
}

struct Scenario: Decodable {
  let name: String
  let timeZone: String
  /// Leave both out for photos without a location.
  let latitude: Double?
  let longitude: Double?
  let daysAgo: Int
  /// Local time in `timeZone`, "HH:mm".
  let start: String
  /// Time from the first burst to the last.
  let minutes: Int
  let bursts: Int
  let hue: Double
  /// Shots per burst, picked at random in this range. Defaults to 1–5.
  let burstSize: [Int]?
  /// Chance that a shot in a burst of 3 or more is blurry. Defaults to 0.25.
  let blurryRate: Double?
}

/// Same seed, same sequence, so every run produces the same library.
struct SeededRandom {
  var state: UInt64
  mutating func next() -> Double {
    state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    return Double(state >> 11) / Double(1 << 53)
  }
}

let arguments = CommandLine.arguments
let usage =
  "Usage: swift generate.swift <seed.json> <output-dir> [bulk-count]\n       swift generate.swift --list <seeds-dir>"

func loadSeed(_ url: URL) throws -> Seed {
  try JSONDecoder().decode(Seed.self, from: Data(contentsOf: url))
}

if arguments.count == 3, arguments[1] == "--list" {
  let directory = URL(fileURLWithPath: arguments[2])
  let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
    .filter { $0.pathExtension == "json" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
  for file in files {
    let name = file.deletingPathExtension().lastPathComponent
    print("  \(name.padding(toLength: 12, withPad: " ", startingAt: 0)) \(try loadSeed(file).description)")
  }
  exit(0)
}

guard arguments.count >= 3 else {
  print(usage)
  exit(1)
}
let seed: Seed
do {
  seed = try loadSeed(URL(fileURLWithPath: arguments[1]))
} catch {
  print("Couldn't read \(arguments[1]): \(error)")
  exit(1)
}
let outputDirectory = URL(fileURLWithPath: arguments[2])
let bulkCount = arguments.count > 3 ? Int(arguments[3]) ?? 0 : 0

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
for (index, scenario) in seed.scenarios.enumerated() {
  guard let timeZone = TimeZone(identifier: scenario.timeZone) else {
    print("Unknown time zone \"\(scenario.timeZone)\" in \(scenario.name)")
    exit(1)
  }
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = timeZone
  let parts = scenario.start.split(separator: ":").compactMap { Int($0) }
  let day = calendar.date(byAdding: .day, value: -scenario.daysAgo, to: calendar.startOfDay(for: .now))!
  let start = calendar.date(bySettingHour: parts[0], minute: parts[1], second: 0, of: day)!
  let place = scenario.latitude.flatMap { lat in scenario.longitude.map { (latitude: lat, longitude: $0) } }
  let sizeRange = scenario.burstSize ?? [1, 5]
  let blurryRate = scenario.blurryRate ?? 0.25

  var shots = 0
  for burst in 0..<scenario.bursts {
    let step = scenario.bursts > 1 ? Double(scenario.minutes * 60) / Double(scenario.bursts - 1) : 0
    let burstStart = start.addingTimeInterval(step * Double(burst))
    // Wander a little within the place (up to ~300 m) so locations aren't identical.
    let coordinate = place.map {
      (latitude: $0.latitude + (random.next() - 0.5) * 0.005, longitude: $0.longitude + (random.next() - 0.5) * 0.005)
    }
    let burstSize = sizeRange[0] + Int(random.next() * Double(sizeRange[1] - sizeRange[0] + 1))
    let compositionSeed = UInt64(index * 1000 + burst + 1)
    for shot in 0..<burstSize {
      let date = burstStart.addingTimeInterval(Double(shot) * (1 + random.next() * 2))
      let blurry = burstSize > 2 && random.next() < blurryRate
      let image = drawShot(
        hue: scenario.hue, compositionSeed: compositionSeed, shift: CGFloat(shot) * 14, blurry: blurry)
      let name = String(format: "seed-%02d-b%02d-s%d%@.jpg", index, burst, shot, blurry ? "-blurry" : "")
      write(image, named: name, date: date, timeZone: timeZone, coordinate: coordinate)
      shots += 1
    }
  }
  total += shots
  var style = Date.FormatStyle.dateTime.month(.abbreviated).day().hour().minute().timeZone()
  style.timeZone = timeZone
  print("  \(scenario.name): \(shots) photos in \(scenario.bursts) bursts, from \(start.formatted(style))")
}

// Filler for scroll testing: one photo per minute from midnight 27 days ago, no location.
// No seed uses that day, so the filler doesn't merge into another moment.
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
if !seed.expected.isEmpty {
  print("The app should find:")
  for line in seed.expected {
    print("  - \(line)")
  }
}
