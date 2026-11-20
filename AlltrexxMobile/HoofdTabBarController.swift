import UIKit

/// Hoofdnavigatie ná typeselectie: status, eigen live kaart en de live kaart
/// van alltrexx.live als aparte tabs.
final class HoofdTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let status = StatusViewController()
        status.tabBarItem = UITabBarItem(title: String(localized: "Status"), image: UIImage(systemName: "info.circle"), tag: 0)

        let kaart = KaartViewController()
        kaart.tabBarItem = UITabBarItem(title: "Tracking", image: UIImage(systemName: "map"), tag: 1)

        let liveKaart = LiveKaartViewController()
        liveKaart.tabBarItem = UITabBarItem(title: String(localized: "Live kaart"), image: UIImage(systemName: "globe.europe.africa"), tag: 2)

        viewControllers = [status, kaart, liveKaart]
    }

    // Alleen actief met het startargument `-screenshot-tab` (store-screenshots); anders geen effect.
    private var screenshotTabGezet = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Alleen voor store-screenshots: `-screenshot-tab <n>` opent direct dat tabblad.
        guard !screenshotTabGezet else { return }
        screenshotTabGezet = true
        let tab = UserDefaults.standard.integer(forKey: "screenshot-tab")
        guard (1..<3).contains(tab), let vcs = viewControllers else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.selectedViewController = vcs[tab]
        }
    }
}
