import Foundation

/// Bewaart het eigen tracker-token (na typeselectie) lokaal op het toestel.
enum TrackerOpslag {
    private static let tokenKey = "alltrexx-token"
    private static let typeKey = "alltrexx-type"
    private static let trackingActiefKey = "alltrexx-tracking-actief"
    private static let naamPerTypeKey = "alltrexx-naam-per-type"

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

    /// Onthoudt per categorie (persoon, boot, ...) de laatst gebruikte naam,
    /// zodat je die terugziet als je later nog eens dezelfde categorie kiest.
    static func laatsteNaam(voor type: TrackerType) -> String? {
        let dict = UserDefaults.standard.dictionary(forKey: naamPerTypeKey) as? [String: String] ?? [:]
        return dict[type.rawValue]
    }

    static func bewaarNaam(_ naam: String, voor type: TrackerType) {
        var dict = UserDefaults.standard.dictionary(forKey: naamPerTypeKey) as? [String: String] ?? [:]
        dict[type.rawValue] = naam
        UserDefaults.standard.set(dict, forKey: naamPerTypeKey)
    }
}
