import UIKit
import StoreKit

/// Instellingen / info: optionele kaartlagen (neerslag + luchtvaart), een schakelaar
/// om de neerslag-laag standaard te tonen, een fooienpot om de ontwikkeling te steunen
/// en een knop om de app te beoordelen.
final class InstellingenViewController: UIViewController {

    private let owmStatus = UILabel()
    private let aipStatus = UILabel()
    private let neerslagSchakelaar = UISwitch()
    private let fooiStack = UIStackView()
    private let fooiInfo = UILabel()
    private var fooiProducten: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Instellingen"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sluit))
        bouwLayout()
        werkStatusBij()
        laadFooien()
    }

    @objc private func sluit() {
        dismiss(animated: true)
    }

    // MARK: - Layout

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
                OWMSleutel.neerslagStandaard = false
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

        let stack = UIStackView(arrangedSubviews: [uitleg, owmBlok, maakNeerslagRij(), aipBlok, maakSteunBlok(), versie])
        stack.axis = .vertical
        stack.spacing = 28
        stack.translatesAutoresizingMaskIntoConstraints = false

        // In een scrollview zodat de (langere) inhoud ook op kleinere toestellen past.
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -24),
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

    /// Schakelaar om de neerslag-laag standaard te tonen zodra je de Tracking-kaart opent.
    private func maakNeerslagRij() -> UIView {
        let label = UILabel()
        label.text = "Neerslag tonen op de kaart"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0

        neerslagSchakelaar.isOn = OWMSleutel.neerslagStandaard
        neerslagSchakelaar.addAction(UIAction { [weak self] _ in self?.neerslagGewijzigd() }, for: .valueChanged)

        let rij = UIStackView(arrangedSubviews: [label, neerslagSchakelaar])
        rij.axis = .horizontal
        rij.alignment = .center
        rij.spacing = 12
        return rij
    }

    private func neerslagGewijzigd() {
        if neerslagSchakelaar.isOn, OWMSleutel.waarde?.isEmpty != false {
            // Geen sleutel: vraag er eerst om; lukt dat niet, zet de schakelaar terug.
            vraagSleutel(titel: "OpenWeatherMap-sleutel", huidige: OWMSleutel.waarde) { [weak self] sleutel in
                guard let self else { return }
                OWMSleutel.waarde = sleutel
                let heeftSleutel = (sleutel?.isEmpty == false)
                OWMSleutel.neerslagStandaard = heeftSleutel
                self.neerslagSchakelaar.setOn(heeftSleutel, animated: true)
                self.werkStatusBij()
            }
            return
        }
        OWMSleutel.neerslagStandaard = neerslagSchakelaar.isOn
    }

    // MARK: - Steun Alltrexx (fooienpot + beoordelen)

    private func maakSteunBlok() -> UIView {
        let titel = UILabel()
        titel.text = "❤️ Steun Alltrexx"
        titel.font = .systemFont(ofSize: 17, weight: .semibold)

        fooiInfo.text = "Alltrexx Mobile is gratis. Met een kleine fooi steun je de verdere ontwikkeling — helemaal vrijblijvend."
        fooiInfo.font = .systemFont(ofSize: 14)
        fooiInfo.textColor = .secondaryLabel
        fooiInfo.numberOfLines = 0

        fooiStack.axis = .vertical
        fooiStack.spacing = 10
        toonFooiPlaatshouder("Donaties laden…")

        let reviewKnop = UIButton(configuration: .gray())
        reviewKnop.configuration?.title = "⭐ Beoordeel Alltrexx Mobile"
        reviewKnop.configuration?.cornerStyle = .large
        reviewKnop.addAction(UIAction { [weak self] _ in self?.vraagReview() }, for: .touchUpInside)

        let blok = UIStackView(arrangedSubviews: [titel, fooiInfo, fooiStack, reviewKnop])
        blok.axis = .vertical
        blok.spacing = 12
        blok.setCustomSpacing(18, after: fooiStack)
        return blok
    }

    private func laadFooien() {
        Task { @MainActor in
            fooiProducten = await Fooienpot.producten()
            bouwFooiKnoppen()
        }
    }

    @MainActor
    private func bouwFooiKnoppen() {
        fooiStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !fooiProducten.isEmpty else {
            toonFooiPlaatshouder("Donaties zijn binnenkort beschikbaar.")
            return
        }
        for product in fooiProducten {
            let knop = UIButton(configuration: .tinted())
            knop.configuration?.title = Fooienpot.label(voor: product)
            knop.configuration?.cornerStyle = .large
            knop.contentHorizontalAlignment = .center
            knop.addAction(UIAction { [weak self] _ in self?.koopFooi(product) }, for: .touchUpInside)
            fooiStack.addArrangedSubview(knop)
        }
    }

    @MainActor
    private func toonFooiPlaatshouder(_ tekst: String) {
        fooiStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = tekst
        label.font = .systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        fooiStack.addArrangedSubview(label)
    }

    private func koopFooi(_ product: Product) {
        Task { @MainActor in
            let gelukt = await Fooienpot.koop(product)
            if gelukt {
                let alert = UIAlertController(title: "Bedankt! 🙏", message: "Je bijdrage helpt Alltrexx verder te ontwikkelen.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Graag gedaan", style: .default))
                present(alert, animated: true)
            }
        }
    }

    private func vraagReview() {
        // Directe link naar het recensie-formulier zodra de App Store-id bekend is;
        // anders de ingebouwde beoordelingsprompt.
        if let id = Fooienpot.appStoreId,
           let url = URL(string: "https://apps.apple.com/app/id\(id)?action=write-review") {
            UIApplication.shared.open(url)
        } else if let scene = view.window?.windowScene {
            AppStore.requestReview(in: scene)
        }
    }

    // MARK: - Sleutelinvoer

    private func vraagSleutel(titel: String, huidige: String?, opslaan: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: titel, message: "Plak hier je gratis API-sleutel.", preferredStyle: .alert)
        alert.addTextField {
            $0.text = huidige
            $0.placeholder = "API-sleutel"
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel) { [weak self] _ in
            // Bij annuleren de neerslag-schakelaar terugzetten als er (nog) geen sleutel is.
            self?.neerslagSchakelaar.setOn(OWMSleutel.neerslagStandaard, animated: true)
        })
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

// MARK: - Fooienpot (StoreKit 2 tip jar)

/// Kleine, vrijblijvende fooienpot om de ontwikkeling te steunen. Drie consumable
/// in-app-aankopen; ze geven geen extra functies, puur een bedankje. De producten
/// moeten in App Store Connect (onder hetzelfde app-record) worden aangemaakt met
/// deze ID's; tot die tijd toont het scherm netjes "binnenkort beschikbaar".
enum Fooienpot {
    /// App Store-id van het record "AllTreXX for all your tracks" — directe "schrijf een recensie"-link.
    static let appStoreId: String? = "1553691366"

    static let productIDs = [
        "info.cafferata.alltrexx.tip.klein",
        "info.cafferata.alltrexx.tip.gemiddeld",
        "info.cafferata.alltrexx.tip.groot",
    ]

    static func producten() async -> [Product] {
        guard let producten = try? await Product.products(for: productIDs) else { return [] }
        return producten.sorted { $0.price < $1.price }
    }

    static func koop(_ product: Product) async -> Bool {
        guard let resultaat = try? await product.purchase() else { return false }
        guard case .success(let verificatie) = resultaat,
              case .verified(let transactie) = verificatie else { return false }
        await transactie.finish()   // consumable: direct afronden, geen entitlement om te bewaren
        return true
    }

    static func label(voor product: Product) -> String {
        let naam: String
        if product.id.hasSuffix(".klein") { naam = "☕️ Kleine fooi" }
        else if product.id.hasSuffix(".gemiddeld") { naam = "🥐 Gemiddelde fooi" }
        else if product.id.hasSuffix(".groot") { naam = "🍰 Grote fooi" }
        else { naam = product.displayName }
        return "\(naam) — \(product.displayPrice)"
    }
}
