import UIKit

/// Hoofdnavigatie ná typeselectie: status, eigen live kaart en de live kaart
/// van alltrexx.live als aparte tabs.
final class HoofdTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let status = StatusViewController()
        status.tabBarItem = UITabBarItem(title: "Status", image: UIImage(systemName: "info.circle"), tag: 0)

        let kaart = KaartViewController()
        kaart.tabBarItem = UITabBarItem(title: "Kaart", image: UIImage(systemName: "map"), tag: 1)

        let liveKaart = LiveKaartViewController()
        liveKaart.tabBarItem = UITabBarItem(title: "Live kaart", image: UIImage(systemName: "globe.europe.africa"), tag: 2)

        viewControllers = [status, kaart, liveKaart]
    }
}
