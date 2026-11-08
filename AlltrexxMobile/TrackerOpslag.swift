import Foundation

/// Bewaart het eigen tracker-token (na typeselectie) lokaal op het toestel.
enum TrackerOpslag {
    private static let tokenKey = "alltrexx-token"
    private static let typeKey = "alltrexx-type"
    private static let trackingActiefKey = "alltrexx-tracking-actief"
    private static let naamPerTypeKey = "alltrexx-naam-per-type"
    private static let trackerIdKey = "alltrexx-tracker-id"
    private static let onboardingGezienKey = "alltrexx-onboarding-gezien"
    private static let tokenPerTypeKey = "alltrexx-token-per-type"
    private static let trackerIdPerTypeKey = "alltrexx-tracker-id-per-type"

    static var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    static var type: TrackerType? {
        get { UserDefaults.standard.string(forKey: typeKey).flatMap(TrackerType.init(rawValue:)) }
        set { UserDefaults.standard.set(newValue?.rawValue, forKey: typeKey) }
    }

    /// Het numerieke tracker-id van de server (uit de sleutel-aanvraag), zodat we
    /// later naar precies deze tracker op alltrexx.live kunnen verwijzen.
    static var trackerId: Int? {
        get {
            let waarde = UserDefaults.standard.integer(forKey: trackerIdKey)
            return waarde > 0 ? waarde : nil
        }
        set { UserDefaults.standard.set(newValue ?? 0, forKey: trackerIdKey) }
    }

    /// Of de gebruiker tracking heeft aangezet — bepaalt of `LocatieManager` bij
    /// app-start automatisch weer moet beginnen met positie-updates versturen.
    static var trackingActief: Bool {
        get { UserDefaults.standard.bool(forKey: trackingActiefKey) }
        set { UserDefaults.standard.set(newValue, forKey: trackingActiefKey) }
    }

    /// Of het eenmalige introscherm al is getoond. Wordt NIET gewist bij
    /// 'Verwijder mijn gegevens' — eenmaal gezien blijft gezien.
    static var onboardingGezien: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingGezienKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingGezienKey) }
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

    /// Onthoudt per categorie de aangemaakte sleutel (token + tracker-id), zodat je bij
    /// het opnieuw kiezen van datzelfde type dezelfde tracker hergebruikt in plaats van
    /// telkens een nieuwe sleutel bij de server aan te vragen.
    static func sleutelVoor(_ type: TrackerType) -> (token: String, trackerId: Int)? {
        let tokens = UserDefaults.standard.dictionary(forKey: tokenPerTypeKey) as? [String: String] ?? [:]
        guard let token = tokens[type.rawValue], !token.isEmpty else { return nil }
        let ids = UserDefaults.standard.dictionary(forKey: trackerIdPerTypeKey) as? [String: Int] ?? [:]
        return (token, ids[type.rawValue] ?? 0)
    }

    static func bewaarSleutel(token: String, trackerId: Int, voor type: TrackerType) {
        var tokens = UserDefaults.standard.dictionary(forKey: tokenPerTypeKey) as? [String: String] ?? [:]
        tokens[type.rawValue] = token
        UserDefaults.standard.set(tokens, forKey: tokenPerTypeKey)
        var ids = UserDefaults.standard.dictionary(forKey: trackerIdPerTypeKey) as? [String: Int] ?? [:]
        ids[type.rawValue] = trackerId
        UserDefaults.standard.set(ids, forKey: trackerIdPerTypeKey)
    }

    /// Wist alle lokaal bewaarde trackergegevens (voor 'Verwijder mijn gegevens').
    static func wisAlles() {
        let defaults = UserDefaults.standard
        [tokenKey, typeKey, trackingActiefKey, naamPerTypeKey, trackerIdKey,
         tokenPerTypeKey, trackerIdPerTypeKey].forEach {
            defaults.removeObject(forKey: $0)
        }
    }
}
