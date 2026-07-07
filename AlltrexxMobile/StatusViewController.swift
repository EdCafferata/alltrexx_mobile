import UIKit

/// Scherm ná typeselectie: toont het gekozen type en de sleutel, en laat de
/// gebruiker tracking starten/stoppen of de sleutel wissen om opnieuw te beginnen.
final class StatusViewController: UIViewController {

    private let titelLabel = UILabel()
    private let statusLabel = UILabel()
    private let trackingKnop = UIButton(configuration: .filled())
    private let wisKnop = UIButton(configuration: .plain())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwLayout()
        werkStatusBij()

        if TrackerOpslag.trackingActief {
            LocatieManager.shared.start()
        }
    }

    private func bouwLayout() {
        titelLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titelLabel.textAlignment = .center

        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        trackingKnop.configuration?.cornerStyle = .large
        trackingKnop.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        trackingKnop.heightAnchor.constraint(equalToConstant: 56).isActive = true
        trackingKnop.addAction(UIAction { [weak self] _ in self?.tikTracking() }, for: .touchUpInside)

        wisKnop.setTitle("Sleutel wissen en opnieuw instellen", for: .normal)
        wisKnop.addAction(UIAction { [weak self] _ in self?.tikWissen() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titelLabel, statusLabel, trackingKnop, wisKnop])
        stack.axis = .vertical
        stack.spacing = 20
        stack.setCustomSpacing(32, after: statusLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    private func werkStatusBij() {
        let type = TrackerOpslag.type
        titelLabel.text = "\(type?.emoji ?? "") \(type?.label ?? "")"

        let tokenKort = TrackerOpslag.token.map { String($0.suffix(6)) } ?? "onbekend"
        statusLabel.text = "Toestel: \(UIDevice.current.name)\nSleutel eindigt op …\(tokenKort)"

        let actief = TrackerOpslag.trackingActief
        trackingKnop.configuration?.title = actief ? "Tracking stoppen" : "Tracking starten"
        trackingKnop.configuration?.baseBackgroundColor = actief ? .systemRed : .systemGreen
    }

    private func tikTracking() {
        let nieuweStatus = !TrackerOpslag.trackingActief
        TrackerOpslag.trackingActief = nieuweStatus
        nieuweStatus ? LocatieManager.shared.start() : LocatieManager.shared.stop()
        werkStatusBij()
    }

    private func tikWissen() {
        let alert = UIAlertController(
            title: "Weet je het zeker?",
            message: "De sleutel wordt gewist en tracking gestopt. Je kunt daarna opnieuw een type kiezen.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel))
        alert.addAction(UIAlertAction(title: "Wissen", style: .destructive) { [weak self] _ in
            self?.wisSleutelEnGaTerug()
        })
        present(alert, animated: true)
    }

    private func wisSleutelEnGaTerug() {
        LocatieManager.shared.stop()
        TrackerOpslag.token = nil
        TrackerOpslag.type = nil
        TrackerOpslag.trackingActief = false
        view.window?.rootViewController = TypeSelectieViewController()
    }
}
