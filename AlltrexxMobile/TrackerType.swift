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

    /// Kaart-preset op alltrexx.live (KAART_PRESETS in TrackerKaart.js), zodat de
    /// live kaart meteen de juiste kaartlaag + opties voor dit type toont.
    var webPreset: String {
        switch self {
        case .person: return "wandel"
        case .boat: return "boot"
        case .bike: return "fiets"
        case .car: return "auto"
        case .train: return "trein"
        case .plane: return "vlieg"
        }
    }
}
