/// What the geocoder knows about a spot, from most to least specific.
nonisolated struct Place: Codable, Sendable {
  let venue: String?
  let neighborhood: String?
  let city: String?
}
