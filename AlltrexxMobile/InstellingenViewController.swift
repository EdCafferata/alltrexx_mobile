import UIKit

/// Instellingen: optionele kaartsleutels (OpenWeatherMap neerslag, OpenAIP
/// luchtvaart) invoeren of wissen. Zonder sleutel worden die lagen simpelweg
/// verborgen; de app werkt verder volledig.
final class InstellingenViewController: UIViewController {

    private let owmStatus = UILabel()
    private let aipStatus = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Instellingen"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sluit))
        bouwLayout()
        werkStatusBij()
    }

    @objc private func sluit() {
        dismiss(animated: true)
    }

    private func bouwLayout() {
        let uitleg = UILabel()
        uitleg.text = "Optionele kaartlagen. Zonder sleutel worden deze lagen verborgen; de app werkt verder gewoon."
        uitleg.font = .systemFont(ofSize: 14)
        uitleg.textColor = .secondaryLabel
        uitleg.numberOfLines = 0

        let owmBlok = maakBlok(
            titel: "🌧 Neerslag (OpenWeatherMap)",
            statusLabel: owmStatus,
            instellen: { [weak self] in
                self?.vraagSleutel(titel: "OpenWeatherMap-sleutel", huidige: OWMSleutel.waarde) {
                    OWMSleutel.waarde = $0
                    self?.werkStatusBij()
                }
            },
            wissen: { [weak self] in
                OWMSleutel.waarde = nil
                self?.werkStatusBij()
            }
        )

        let aipBlok = maakBlok(
            titel: "✈️ Luchtvaart (OpenAIP)",
            statusLabel: aipStatus,
            instellen: { [weak self] in
                self?.vraagSleutel(titel: "OpenAIP-sleutel", huidige: OpenAIPSleutel.waarde) {
                    OpenAIPSleutel.waarde = $0
                    self?.werkStatusBij()
                }
            },
            wissen: { [weak self] in
                OpenAIPSleutel.waarde = nil
                self?.werkStatusBij()
            }
        )

        let versie = UILabel()
        let kort = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        versie.text = "Alltrexx Mobile \(kort) (\(build))"
        versie.font = .systemFont(ofSize: 13)
        versie.textColor = .tertiaryLabel
        versie.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [uitleg, owmBlok, aipBlok, versie])
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])
    }

    private func maakBlok(titel: String, statusLabel: UILabel, instellen: @escaping () -> Void, wissen: @escaping () -> Void) -> UIView {
        let titelLabel = UILabel()
        titelLabel.text = titel
        titelLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titelLabel.numberOfLines = 0

        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel

        let instelKnop = UIButton(configuration: .tinted())
        instelKnop.configuration?.title = "Sleutel instellen"
        instelKnop.addAction(UIAction { _ in instellen() }, for: .touchUpInside)

        let wisKnop = UIButton(configuration: .plain())
        wisKnop.configuration?.title = "Wissen"
        wisKnop.configuration?.baseForegroundColor = .systemRed
        wisKnop.addAction(UIAction { _ in wissen() }, for: .touchUpInside)

        let knoppen = UIStackView(arrangedSubviews: [instelKnop, wisKnop, UIView()])
        knoppen.axis = .horizontal
        knoppen.spacing = 12

        let blok = UIStackView(arrangedSubviews: [titelLabel, statusLabel, knoppen])
        blok.axis = .vertical
        blok.spacing = 8
        return blok
    }

    private func vraagSleutel(titel: String, huidige: String?, opslaan: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: titel, message: "Plak hier je gratis API-sleutel.", preferredStyle: .alert)
        alert.addTextField {
            $0.text = huidige
            $0.placeholder = "API-sleutel"
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel))
        alert.addAction(UIAlertAction(title: "Opslaan", style: .default) { [weak alert] _ in
            let tekst = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            opslaan(tekst?.isEmpty == false ? tekst : nil)
        })
        present(alert, animated: true)
    }

    private func werkStatusBij() {
        owmStatus.text = (OWMSleutel.waarde?.isEmpty == false) ? "✓ Sleutel ingesteld" : "Geen sleutel — laag verborgen"
        aipStatus.text = (OpenAIPSleutel.waarde?.isEmpty == false) ? "✓ Sleutel ingesteld" : "Geen sleutel — laag verborgen"
    }
}
