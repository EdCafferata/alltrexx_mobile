import UIKit

/// Eerste scherm van de app: kies wat voor tracker dit toestel is
/// (persoon, boot, fiets, auto, trein, vliegtuig) — zelfde typen als op de
/// webkaart van Alltrexx Live. Elke categorie vraagt om een eigen naam (met de
/// laatst gebruikte naam als voorstel) en de actief gekozen categorie wordt
/// gemarkeerd. Na keuze wordt er een gratis inlogsleutel aangemaakt bij de
/// server en lokaal bewaard.
final class TypeSelectieViewController: UIViewController {

    private let titelLabel: UILabel = {
        let label = UILabel()
        label.text = "Alltrexx Mobile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let toelichtingLabel: UILabel = {
        let label = UILabel()
        label.text = "Wat wil je volgen met dit toestel?"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwLayout()
    }

    private func bouwLayout() {
        let knoppenStack = UIStackView(arrangedSubviews: TrackerType.allCases.map(maakTypeKnop))
        knoppenStack.axis = .vertical
        knoppenStack.spacing = 12
        knoppenStack.distribution = .fillEqually

        let hoofdStack = UIStackView(arrangedSubviews: [titelLabel, toelichtingLabel, knoppenStack, activityIndicator])
        hoofdStack.axis = .vertical
        hoofdStack.spacing = 24
        hoofdStack.setCustomSpacing(40, after: toelichtingLabel)
        hoofdStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hoofdStack)
        NSLayoutConstraint.activate([
            hoofdStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            hoofdStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            hoofdStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    private func maakTypeKnop(voor type: TrackerType) -> UIButton {
        let isActief = TrackerOpslag.heeftSleutel && TrackerOpslag.type == type
        let naam = TrackerOpslag.laatsteNaam(voor: type)

        var config = UIButton.Configuration.filled()
        config.title = isActief ? "\(type.emoji)  \(type.label)  ✓" : "\(type.emoji)  \(type.label)"
        config.subtitle = naam
        config.baseBackgroundColor = isActief ? .systemGreen : .secondarySystemBackground
        config.baseForegroundColor = isActief ? .white : .label
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.vraagNaamEnKies(type) }, for: .touchUpInside)
        return button
    }

    private func vraagNaamEnKies(_ type: TrackerType) {
        let voorstel = TrackerOpslag.laatsteNaam(voor: type) ?? UIDevice.current.name

        let alert = UIAlertController(
            title: "\(type.emoji) \(type.label)",
            message: "Onder welke naam wil je dit toestel laten zien op Alltrexx Live?",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.text = voorstel
            textField.placeholder = "Naam"
        }
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kiezen", style: .default) { [weak self, weak alert] _ in
            let naam = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.kiesType(type, naam: (naam?.isEmpty == false) ? naam! : voorstel)
        })
        present(alert, animated: true)
    }

    private func kiesType(_ type: TrackerType, naam: String) {
        activityIndicator.startAnimating()

        AlltrexxAPI.maakSleutel(naam: naam, type: type) { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            switch result {
            case .success(let sleutel):
                TrackerOpslag.token = sleutel.token
                TrackerOpslag.type = type
                TrackerOpslag.trackingActief = true
                TrackerOpslag.bewaarNaam(naam, voor: type)
                self.view.window?.rootViewController = HoofdTabBarController()
            case .failure(let error):
                self.toonMelding(titel: "Mislukt", tekst: "Kon geen sleutel aanmaken: \(error.localizedDescription)")
            }
        }
    }

    private func toonMelding(titel: String, tekst: String) {
        let alert = UIAlertController(title: titel, message: tekst, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
