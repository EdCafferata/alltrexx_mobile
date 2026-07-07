import Foundation

/// Bewaart de (optionele) OpenWeatherMap API-sleutel voor de neerslag-laag op de kaart —
/// dezelfde sleutel die ook in BVK GPX Tracker wordt gebruikt.
enum OWMSleutel {
    private static let key = "alltrexx-owm-api-key"

    static var waarde: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
