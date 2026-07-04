import Foundation

/// De typen die Alltrexx Live kent (zelfde set als de webkaart: BOAT/BIKE/CAR/TRAIN/PLANE/PERSON).
enum TrackerType: String, CaseIterable {
    case person = "PERSON"
    case boat = "BOAT"
    case bike = "BIKE"
    case car = "CAR"
    case train = "TRAIN"
    case plane = "PLANE"

    var label: String {
        switch self {
        case .person: return "Persoon"
        case .boat: return "Boot"
        case .bike: return "Fiets"
        case .car: return "Auto"
        case .train: return "Trein"
        case .plane: return "Vliegtuig"
        }
    }

    var emoji: String {
        switch self {
        case .person: return "🧍"
        case .boat: return "⛵"
        case .bike: return "🚴"
        case .car: return "🚗"
        case .train: return "🚆"
        case .plane: return "✈️"
        }
    }
}
