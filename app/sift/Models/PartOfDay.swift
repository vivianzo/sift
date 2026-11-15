nonisolated enum PartOfDay: String, CaseIterable, Sendable {
  case morning
  case afternoon
  case evening
  case night

  init(hour: Int) {
    switch hour {
    case 5..<12: self = .morning
    case 12..<17: self = .afternoon
    case 17..<22: self = .evening
    default: self = .night
    }
  }
}
