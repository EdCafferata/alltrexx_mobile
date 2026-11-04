import UIKit
import CoreLocation

/// Statusscherm ná typeselectie: toont live wat er gebeurt (tracking aan/uit,
/// laatste positie, wachtrij, snelheid) en laat je tracking starten/stoppen,
/// jezelf live bekijken, instellingen openen, van naam/type wisselen of al je
/// gegevens verwijderen.
final class StatusViewController: UIViewController {

    private let titelLabel = UILabel()
    private let naamLabel = UILabel()
    private let statusLabel = UILabel()
    private let trackingKnop = UIButton(configuration: .filled())
    private let mijnKaartKnop = UIButton(configuration: .filled())
    private let bekijkLiveKnop = UIButton(configuration: .filled())
    private let instellingenKnop = UIButton(configuration: .gray())
    private let wijzigKnop = UIButton(configuration: .plain())
    private let verwijderKnop = UIButton(configuration: .plain())

    private var laatsteLocatie: CLLocation?
    private var verversTimer: Timer?
    private let relatieveTijd = RelativeDateTimeFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        relatieveTijd.unitsStyle = .short
        bouwLayout()
        LocatieManager.shared.voegWaarnemerToe(self)
        werkStatusBij()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        werkStatusBij()
        verversTimer?.invalidate()
        verversTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.werkStatusBij()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        verversTimer?.invalidate()
        verversTimer = nil
    }

    deinit {
        LocatieManager.shared.verwijderWaarnemer(self)
        verversTimer?.invalidate()
    }

    private func bouwLayout() {
        titelLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titelLabel.textAlignment = .center

        naamLabel.font = .systemFont(ofSize: 17, weight: .medium)
        naamLabel.textColor = .secondaryLabel
        naamLabel.textAlignment = .center

        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center

        configureerKnop(trackingKnop, hoogte: 56) { [weak self] in self?.tikTracking() }

        mijnKaartKnop.configuration?.title = "🗺 Mijn kaart"
        mijnKaartKnop.configuration?.baseBackgroundColor = .systemIndigo
        configureerKnop(mijnKaartKnop, hoogte: 50) { [weak self] in self?.tabBarController?.selectedIndex = 1 }

        bekijkLiveKnop.configuration?.title = "🌐 Bekijk mij live"
        bekijkLiveKnop.configuration?.baseBackgroundColor = .systemBlue
        configureerKnop(bekijkLiveKnop, hoogte: 50) { [weak self] in self?.tabBarController?.selectedIndex = 2 }

        instellingenKnop.configuration?.title = "⚙︎ Instellingen"
        configureerKnop(instellingenKnop, hoogte: 44) { [weak self] in self?.tikInstellingen() }

        wijzigKnop.setTitle("Naam of type wijzigen", for: .normal)
        wijzigKnop.addAction(UIAction { [weak self] _ in self?.tikWijzigen() }, for: .touchUpInside)

        verwijderKnop.setTitle("Verwijder mijn gegevens", for: .normal)
        verwijderKnop.setTitleColor(.systemRed, for: .normal)
        verwijderKnop.addAction(UIAction { [weak self] _ in self?.tikVerwijderen() }, for: .touchUpInside)

        let kaartRij = UIStackView(arrangedSubviews: [mijnKaartKnop, bekijkLiveKnop])
        kaartRij.axis = .horizontal
        kaartRij.spacing = 12
        kaartRij.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [titelLabel, naamLabel, statusLabel, trackingKnop, kaartRij, instellingenKnop, wijzigKnop, verwijderKnop])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(18, after: naamLabel)
        stack.setCustomSpacing(24, after: statusLabel)
        stack.setCustomSpacing(20, after: instellingenKnop)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    private func configureerKnop(_ knop: UIButton, hoogte: CGFloat, actie: @escaping () -> Void) {
        knop.configuration?.cornerStyle = .large
        knop.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        knop.heightAnchor.constraint(equalToConstant: hoogte).isActive = true
        knop.addAction(UIAction { _ in actie() }, for: .touchUpInside)
    }

    private func werkStatusBij() {
        let type = TrackerOpslag.type
        titelLabel.text = "\(type?.emoji ?? "") \(type?.label ?? "")"
        naamLabel.text = type.flatMap { TrackerOpslag.laatsteNaam(voor: $0) }

        let actief = TrackerOpslag.trackingActief
        trackingKnop.configuration?.title = actief ? "Tracking stoppen" : "Tracking starten"
        trackingKnop.configuration?.baseBackgroundColor = actief ? .systemRed : .systemGreen
        trackingKnop.configuration?.baseForegroundColor = .white

        statusLabel.text = statusTekst(actief: actief)
    }

    private func statusTekst(actief: Bool) -> String {
        var regels: [String] = [actief ? "🟢 Tracking actief" : "⚪️ Tracking gestopt"]

        if let laatste = PositieLogboek.laatste {
            regels.append("Laatste positie: \(relatieveTijd.localizedString(for: laatste.tijdstip, relativeTo: Date()))")
        }

        let wachtrij = PositieLogboek.aantalOnverzonden
        if wachtrij == 0 {
            if PositieLogboek.laatste != nil { regels.append("✓ Alles doorgestuurd") }
        } else {
            regels.append("\(wachtrij) positie(s) wachten op verzending")
        }

        if actief, let locatie = laatsteLocatie, locatie.speed >= 0 {
            regels.append("Snelheid: \(Int((locatie.speed * 3.6).rounded())) km/u")
        }

        let tokenKort = TrackerOpslag.token.map { String($0.suffix(6)) } ?? "onbekend"
        regels.append("Sleutel …\(tokenKort)")
        return regels.joined(separator: "\n")
    }

    private func tikTracking() {
        let nieuw = !TrackerOpslag.trackingActief
        TrackerOpslag.trackingActief = nieuw
        nieuw ? LocatieManager.shared.start() : LocatieManager.shared.stop()
        werkStatusBij()
    }

    private func tikInstellingen() {
        present(UINavigationController(rootViewController: InstellingenViewController()), animated: true)
    }

    private func tikWijzigen() {
        view.window?.rootViewController = TypeSelectieViewController()
    }

    private func tikVerwijderen() {
        let alert = UIAlertController(
            title: "Gegevens verwijderen?",
            message: "Dit stopt de tracking en verwijdert je tracker, sleutel en lokaal opgeslagen posities van dit toestel. Dit kan niet ongedaan worden gemaakt.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel))
        alert.addAction(UIAlertAction(title: "Verwijderen", style: .destructive) { [weak self] _ in
            self?.verwijderDefinitief()
        })
        present(alert, animated: true)
    }

    private func verwijderDefinitief() {
        LocatieManager.shared.stop()
        if let token = TrackerOpslag.token {
            AlltrexxAPI.verwijderTracker(token: token) { _ in }  // best-effort serverkant (backend #25)
        }
        TrackerOpslag.wisAlles()
        PositieLogboek.wisAlles()
        view.window?.rootViewController = TypeSelectieViewController()
    }
}

extension StatusViewController: LocatieWaarnemer {
    func locatieBijgewerkt(_ locatie: CLLocation) {
        laatsteLocatie = locatie
        werkStatusBij()
    }
}
