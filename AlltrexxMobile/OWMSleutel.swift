import Foundation

/// Bewaart de (optionele) OpenWeatherMap API-sleutel voor de neerslag-laag op de kaart —
/// dezelfde sleutel die ook in BVK GPX Tracker wordt gebruikt.
enum OWMSleutel {
    private static let key = "alltrexx-owm-api-key"
    private static let standaardKey = "alltrexx-neerslag-standaard"

    static var waarde: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    /// Of de neerslag-laag standaard getoond wordt zodra je de Tracking-kaart opent
    /// (in te stellen via Instellingen). Werkt alleen als er ook een sleutel is.
    static var neerslagStandaard: Bool {
        get { UserDefaults.standard.bool(forKey: standaardKey) }
        set { UserDefaults.standard.set(newValue, forKey: standaardKey) }
    }
}
