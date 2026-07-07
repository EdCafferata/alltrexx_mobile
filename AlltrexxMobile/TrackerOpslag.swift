import Foundation

/// Bewaart het eigen tracker-token (na typeselectie) lokaal op het toestel.
enum TrackerOpslag {
    private static let tokenKey = "alltrexx-token"
    private static let typeKey = "alltrexx-type"
    private static let trackingActiefKey = "alltrexx-tracking-actief"

    static var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    static var type: TrackerType? {
        get { UserDefaults.standard.string(forKey: typeKey).flatMap(TrackerType.init(rawValue:)) }
        set { UserDefaults.standard.set(newValue?.rawValue, forKey: typeKey) }
    }

    /// Of de gebruiker tracking heeft aangezet — bepaalt of `LocatieManager` bij
    /// app-start automatisch weer moet beginnen met positie-updates versturen.
    static var trackingActief: Bool {
        get { UserDefaults.standard.bool(forKey: trackingActiefKey) }
        set { UserDefaults.standard.set(newValue, forKey: trackingActiefKey) }
    }

    static var heeftSleutel: Bool { token != nil }
}
