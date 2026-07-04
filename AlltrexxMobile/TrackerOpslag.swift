import Foundation

/// Bewaart het eigen tracker-token (na typeselectie) lokaal op het toestel.
enum TrackerOpslag {
    private static let tokenKey = "alltrexx-token"
    private static let typeKey = "alltrexx-type"

    static var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    static var type: TrackerType? {
        get { UserDefaults.standard.string(forKey: typeKey).flatMap(TrackerType.init(rawValue:)) }
        set { UserDefaults.standard.set(newValue?.rawValue, forKey: typeKey) }
    }

    static var heeftSleutel: Bool { token != nil }
}
