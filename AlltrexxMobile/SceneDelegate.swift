import UIKit

/// UIScene-lifecycle (vereist vanaf de iOS 27 SDK / Xcode 27).
/// Bouwt het venster programmatisch op — zelfde startlogica als voorheen in AppDelegate.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let startScherm: UIViewController
        if TrackerOpslag.heeftSleutel {
            startScherm = HoofdTabBarController()
        } else if TrackerOpslag.onboardingGezien {
            startScherm = TypeSelectieViewController()
        } else {
            startScherm = OnboardingViewController()
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = startScherm
        window.makeKeyAndVisible()
        self.window = window
    }
}
