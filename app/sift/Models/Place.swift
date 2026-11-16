/// What the geocoder knows about a spot, from most to least specific.
nonisolated struct Place: Codable, Sendable {
  /// A named place: a venue, park, beach, or monument ("TD Garden", "Revere Beach").
  let landmark: String?
  let neighborhood: String?
  let city: String?
}
