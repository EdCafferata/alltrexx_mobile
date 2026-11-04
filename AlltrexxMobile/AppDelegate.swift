import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Hervat tracking meteen bij (achtergrond-)start, ook als iOS de app
        // opnieuw heeft opgestart na een significante locatiewijziging.
        if TrackerOpslag.trackingActief {
            LocatieManager.shared.start()
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = TrackerOpslag.heeftSleutel ? HoofdTabBarController() : TypeSelectieViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
