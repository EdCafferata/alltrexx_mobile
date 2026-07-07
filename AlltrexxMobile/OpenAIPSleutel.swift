import Foundation

/// Bewaart de (optionele) OpenAIP API-sleutel voor de luchtvaartlaag
/// (vliegvelden & luchtruim) op de kaart — gratis aan te vragen via openaip.net,
/// zelfde sleutel als op de alltrexx.live-webkaart.
enum OpenAIPSleutel {
    private static let key = "alltrexx-openaip-api-key"

    static var waarde: String? {
        get { UserDefaults.standard.string(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
