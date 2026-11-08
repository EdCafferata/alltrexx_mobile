import UIKit
import StoreKit

/// Instellingen / info: optionele kaartlagen (neerslag + luchtvaart), een schakelaar
/// om de neerslag-laag standaard te tonen, een fooienpot om de ontwikkeling te steunen
/// en een knop om de app te beoordelen.
/// Tap-gebaar met een closure, zodat labels/iconen naar een URL kunnen linken.
private final class SluitingTap: UITapGestureRecognizer {
    private let actie: () -> Void
    init(_ actie: @escaping () -> Void) {
        self.actie = actie
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(vuur))
    }
    @objc private func vuur() { actie() }
}

final class InstellingenViewController: UIViewController {

    /// Welk sleutel-veld meteen in beeld + actief moet zijn bij openen
    /// (vanaf de kaart, wanneer die laag nog geen sleutel heeft).
    enum FocusVeld { case owm, openAIP }

    private let focus: FocusVeld?
    /// Aangeroepen bij sluiten, zodat de kaart z'n lagen kan verversen als er
    /// zojuist een sleutel is ingevuld.
    var bijSluiten: (() -> Void)?

    init(focus: FocusVeld? = nil) {
        self.focus = focus
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.focus = nil
        super.init(coder: coder)
    }

    private let owmStatus = UILabel()
    private let aipStatus = UILabel()
    private let owmVeld = UITextField()
    private let aipVeld = UITextField()
    private let neerslagSchakelaar = UISwitch()
    private let fooiStack = UIStackView()
    private let fooiInfo = UILabel()
    private var fooiProducten: [Product] = []

    private let scroll = UIScrollView()
    private var owmBlok: UIView?
    private var aipBlok: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Instellingen"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sluit))
        bouwLayout()
        werkStatusBij()
        laadFooien()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        springNaarFocusVeld()
    }

    /// Scrollt naar het gevraagde sleutelveld en zet de cursor erin — zodat je
    /// vanaf de kaart meteen de ontbrekende sleutel kunt invullen, zonder popup.
    private func springNaarFocusVeld() {
        guard let focus else { return }
        let blok = focus == .owm ? owmBlok : aipBlok
        let veld = focus == .owm ? owmVeld : aipVeld
        if let blok {
            scroll.scrollRectToVisible(blok.frame.insetBy(dx: 0, dy: -24), animated: true)
        }
        veld.becomeFirstResponder()
    }

    @objc private func sluit() {
        view.endEditing(true)
        bijSluiten?()
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
            veld: owmVeld,
            huidige: OWMSleutel.waarde,
            aanvraagURL: URL(string: "https://home.openweathermap.org/api_keys")!,
            aanvraagTitel: "Gratis OpenWeatherMap-sleutel aanvragen",
            bewaar: { [weak self] nieuw in
                OWMSleutel.waarde = nieuw
                if nieuw == nil {
                    OWMSleutel.neerslagStandaard = false
                    self?.neerslagSchakelaar.setOn(false, animated: true)
                }
                self?.werkStatusBij()
            }
        )
        self.owmBlok = owmBlok

        let aipBlok = maakBlok(
            titel: "✈️ Luchtvaart (OpenAIP)",
            statusLabel: aipStatus,
            veld: aipVeld,
            huidige: OpenAIPSleutel.waarde,
            aanvraagURL: URL(string: "https://www.openaip.net/")!,
            aanvraagTitel: "Gratis OpenAIP-sleutel aanvragen",
            bewaar: { [weak self] nieuw in
                OpenAIPSleutel.waarde = nieuw
                self?.werkStatusBij()
            }
        )
        self.aipBlok = aipBlok

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

    private func maakBlok(titel: String, statusLabel: UILabel, veld: UITextField, huidige: String?, aanvraagURL: URL, aanvraagTitel: String, bewaar: @escaping (String?) -> Void) -> UIView {
        let openAanvraag = { UIApplication.shared.open(aanvraagURL) }

        // Titel + icoon: tappable → opent de aanvraagpagina.
        let titelLabel = UILabel()
        titelLabel.text = titel
        titelLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titelLabel.numberOfLines = 0
        titelLabel.isUserInteractionEnabled = true
        titelLabel.addGestureRecognizer(SluitingTap(openAanvraag))

        // Statusregel: ook tappable → aanvraagpagina.
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textColor = .secondaryLabel
        statusLabel.isUserInteractionEnabled = true
        statusLabel.addGestureRecognizer(SluitingTap(openAanvraag))

        // Duidelijke aanvraag-link.
        let aanvraagKnop = UIButton(configuration: .plain())
        aanvraagKnop.configuration?.title = "🔑 \(aanvraagTitel) →"
        aanvraagKnop.configuration?.baseForegroundColor = .systemBlue
        aanvraagKnop.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        aanvraagKnop.contentHorizontalAlignment = .leading
        aanvraagKnop.titleLabel?.numberOfLines = 0
        aanvraagKnop.addAction(UIAction { _ in openAanvraag() }, for: .touchUpInside)

        veld.text = huidige
        veld.placeholder = "Plak hier je gratis API-sleutel"
        veld.borderStyle = .roundedRect
        veld.autocapitalizationType = .none
        veld.autocorrectionType = .no
        veld.clearButtonMode = .whileEditing
        veld.returnKeyType = .done
        veld.font = .systemFont(ofSize: 15)
        // Rechts in het veld een link-knop naar de aanvraagpagina (plakken blijft gewoon werken).
        let veldLink = UIButton(configuration: .plain())
        veldLink.configuration?.image = UIImage(systemName: "arrow.up.right.square")
        veldLink.configuration?.baseForegroundColor = .systemBlue
        veldLink.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        veldLink.addAction(UIAction { _ in openAanvraag() }, for: .touchUpInside)
        veldLink.sizeToFit()
        veld.rightView = veldLink
        veld.rightViewMode = .unlessEditing
        // Opslaan zodra het veld klaar is (Gereed, of focus verliezen).
        veld.addAction(UIAction { _ in
            let tekst = veld.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            bewaar(tekst?.isEmpty == false ? tekst : nil)
        }, for: .editingDidEnd)
        veld.addAction(UIAction { _ in veld.resignFirstResponder() }, for: .editingDidEndOnExit)

        let wisKnop = UIButton(configuration: .plain())
        wisKnop.configuration?.title = "Wissen"
        wisKnop.configuration?.baseForegroundColor = .systemRed
        wisKnop.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0)
        wisKnop.contentHorizontalAlignment = .leading
        wisKnop.addAction(UIAction { _ in
            veld.text = nil
            bewaar(nil)
        }, for: .touchUpInside)

        let blok = UIStackView(arrangedSubviews: [titelLabel, statusLabel, aanvraagKnop, veld, wisKnop])
        blok.axis = .vertical
        blok.spacing = 8
        blok.setCustomSpacing(4, after: veld)
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
            // Geen sleutel: geen popup — zet 'm terug en spring naar het sleutelveld.
            neerslagSchakelaar.setOn(false, animated: true)
            if let owmBlok {
                scroll.scrollRectToVisible(owmBlok.frame.insetBy(dx: 0, dy: -24), animated: true)
            }
            owmVeld.becomeFirstResponder()
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
