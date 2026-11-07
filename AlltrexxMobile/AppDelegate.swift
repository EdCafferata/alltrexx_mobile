import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Hervat tracking meteen bij (achtergrond-)start, ook als iOS de app
        // opnieuw heeft opgestart na een significante locatiewijziging.
        // Blijft in de app-delegate: iOS kan de app in de achtergrond
        // relaunchen (significante locatiewijziging) zonder scene-UI.
        if TrackerOpslag.trackingActief {
            LocatieManager.shared.start()
        }
        return true
    }

    // MARK: - UIScene lifecycle (vereist vanaf de iOS 27 SDK)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration",
                                          sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
