import UIKit
import MapKit

/// Eigen live kaart: toont de positie van dit toestel, de route die deze sessie
/// al is doorgestuurd naar Alltrexx Live, de neerslag-laag van OpenWeatherMap
/// (zelfde als BVK GPX Tracker) en een windpijl op basis van Open-Meteo.
/// De Start/Stop-knop stuurt dezelfde tracking aan als het Status-scherm.
final class KaartViewController: UIViewController {

    private let kaart = MKMapView()
    private let legende = OWMLegendView()
    private let luchtvaartKnop = UIButton(configuration: .filled())
    private let startKnop = UIButton(configuration: .filled())

    private var posities: [CLLocationCoordinate2D] = []
    private var heeftKaartGecentreerd = false
    private var owmOverlay: OWMTileOverlay?
    private var openSeaMapOverlay: OpenSeaMapOverlay?
    private var openTopoMapOverlay: OpenTopoMapOverlay?
    private var openAIPOverlay: OpenAIPOverlay?
    private var laatsteWindOphaal: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwKaart()
        bouwKnoppen()
        pasKaartAanOpCategorie()
        werkWeerWeergaveBij()
        LocatieManager.shared.voegWaarnemerToe(self)
    }

    /// Elke categorie krijgt dezelfde kaartweergave als het bijbehorende preset
    /// op de alltrexx.live-webkaart (KAART_PRESETS in TrackerKaart.js), zodat
    /// Live kaart en Tracking-scherm gelijk blijven:
    /// - Boot: gewone kaart + vaarwegmarkeringen (OpenSeaMap)
    /// - Fiets: CyclOSM-kaart + fietsroutes (Waymarked Trails)
    /// - Auto: gewone kaart, geen extra laag
    /// - Vliegtuig: lichte kaart + luchtvaartlaag (OpenAIP, als er een sleutel is)
    /// - Persoon (wandelen): topografische kaart + wandelroutes (Waymarked Trails)
    /// - Trein: lichte kaart + spoorwegenlaag (OpenRailwayMap)
    private func pasKaartAanOpCategorie() {
        kaart.mapType = .standard

        switch TrackerOpslag.type {
        case .boat:
            let overlay = OpenSeaMapOverlay.make()
            openSeaMapOverlay = overlay
            kaart.addOverlay(overlay, level: .aboveLabels)
        case .bike:
            kaart.addOverlay(CyclOSMOverlay.make())
            kaart.addOverlay(WaymarkedTrailsOverlay.make(.fietsen), level: .aboveRoads)
        case .car:
            break
        case .plane:
            kaart.mapType = .mutedStandard
            toonLuchtvaart(true)
        case .person:
            let overlay = OpenTopoMapOverlay.make()
            openTopoMapOverlay = overlay
            kaart.addOverlay(overlay)
            kaart.addOverlay(WaymarkedTrailsOverlay.make(.wandelen), level: .aboveRoads)
        case .train:
            kaart.mapType = .mutedStandard
            kaart.addOverlay(SpoorwegenOverlay.make(), level: .aboveRoads)
        case .none:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        werkStartKnopBij()
        // Neerslag-laag volgt de instelling (aan/uit staat alleen nog in Instellingen).
        let neerslagAan = OWMSleutel.neerslagStandaard && (OWMSleutel.waarde?.isEmpty == false)
        if neerslagAan != (owmOverlay != nil) {
            toonNeerslag(neerslagAan)
        }
    }

    deinit {
        LocatieManager.shared.verwijderWaarnemer(self)
    }

    private func bouwKaart() {
        kaart.delegate = self
        kaart.showsUserLocation = true
        kaart.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(kaart)
        NSLayoutConstraint.activate([
            kaart.topAnchor.constraint(equalTo: view.topAnchor),
            kaart.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kaart.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kaart.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        legende.translatesAutoresizingMaskIntoConstraints = false
        legende.configure(for: .precipitation)
        view.addSubview(legende)
        NSLayoutConstraint.activate([
            legende.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            legende.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ])
    }

    private func bouwKnoppen() {
        luchtvaartKnop.configuration?.title = "✈️ Luchtvaart"
        luchtvaartKnop.configuration?.cornerStyle = .capsule
        luchtvaartKnop.isHidden = TrackerOpslag.type != .plane
        luchtvaartKnop.addAction(UIAction { [weak self] _ in self?.tikLuchtvaart() }, for: .touchUpInside)

        startKnop.configuration?.cornerStyle = .capsule
        startKnop.addAction(UIAction { [weak self] _ in self?.tikStart() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [luchtvaartKnop, startKnop])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - Weerlaag

    /// Geen popup meer bij een ontbrekende API-sleutel: open Instellingen en spring
    /// direct naar het juiste sleutelveld. Na sluiten wordt de laag alsnog getoond
    /// als de sleutel inmiddels is ingevuld.
    private func openInstellingen(focus: InstellingenViewController.FocusVeld) {
        let instellingen = InstellingenViewController(focus: focus)
        instellingen.bijSluiten = { [weak self] in
            guard let self else { return }
            switch focus {
            case .owm:
                if OWMSleutel.waarde?.isEmpty == false { self.toonNeerslag(true) }
            case .openAIP:
                if OpenAIPSleutel.waarde?.isEmpty == false { self.toonLuchtvaart(true) }
            }
        }
        present(UINavigationController(rootViewController: instellingen), animated: true)
    }

    private func toonNeerslag(_ aan: Bool) {
        if let bestaand = owmOverlay {
            kaart.removeOverlay(bestaand)
            owmOverlay = nil
        }
        if aan, let sleutel = OWMSleutel.waarde, !sleutel.isEmpty {
            let overlay = OWMTileOverlay.make(layer: .precipitation, apiKey: sleutel)
            owmOverlay = overlay
            kaart.addOverlay(overlay, level: .aboveLabels)
        }
        werkWeerWeergaveBij()
    }

    private func werkWeerWeergaveBij() {
        // Legenda alleen tonen als de neerslag-laag actief is (aan/uit via Instellingen).
        legende.isHidden = (owmOverlay == nil)
    }

    // MARK: - Luchtvaartlaag (alleen categorie Vliegtuig)

    private func tikLuchtvaart() {
        guard let sleutel = OpenAIPSleutel.waarde, !sleutel.isEmpty else {
            openInstellingen(focus: .openAIP)
            return
        }
        toonLuchtvaart(!(openAIPOverlay != nil))
    }

    private func toonLuchtvaart(_ aan: Bool) {
        if let bestaand = openAIPOverlay {
            kaart.removeOverlay(bestaand)
            openAIPOverlay = nil
        }
        if aan, let sleutel = OpenAIPSleutel.waarde, !sleutel.isEmpty {
            let overlay = OpenAIPOverlay.make(apiKey: sleutel)
            openAIPOverlay = overlay
            kaart.addOverlay(overlay, level: .aboveRoads)
        }
        werkLuchtvaartWeergaveBij()
    }

    private func werkLuchtvaartWeergaveBij() {
        let aan = openAIPOverlay != nil
        luchtvaartKnop.configuration?.baseBackgroundColor = aan ? .systemBlue : .secondarySystemBackground
        luchtvaartKnop.configuration?.baseForegroundColor = aan ? .white : .label
    }

    // MARK: - Tracking-knop (zelfde status als het Status-scherm)

    private func tikStart() {
        let nieuweStatus = !TrackerOpslag.trackingActief
        TrackerOpslag.trackingActief = nieuweStatus
        nieuweStatus ? LocatieManager.shared.start() : LocatieManager.shared.stop()
        werkStartKnopBij()
    }

    private func werkStartKnopBij() {
        let actief = TrackerOpslag.trackingActief
        startKnop.configuration?.title = actief ? "⏹ Stop" : "▶︎ Start"
        startKnop.configuration?.baseBackgroundColor = actief ? .systemRed : .systemGreen
        startKnop.configuration?.baseForegroundColor = .white
    }

    // MARK: - Wind (Open-Meteo, geen API-sleutel nodig)

    private func werkWindBij(coordinate: CLLocationCoordinate2D) {
        if let laatst = laatsteWindOphaal, Date().timeIntervalSince(laatst) < 5 * 60 {
            return
        }
        laatsteWindOphaal = Date()

        // Privacy: stuur alleen een afgeronde positie (2 decimalen ≈ 1 km) naar Open-Meteo; ruim voldoende voor wind.
        let lat = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), coordinate.latitude)
        let lon = String(format: "%.2f", locale: Locale(identifier: "en_US_POSIX"), coordinate.longitude)
        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=wind_speed_10m,wind_direction_10m&wind_speed_unit=kn"
        guard let url = URL(string: urlStr) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let current = json["current"] as? [String: Any],
                  let speedKn = current["wind_speed_10m"] as? Double,
                  let dirDeg = current["wind_direction_10m"] as? Double else { return }

            let beaufort = self.knopenNaarBeaufort(speedKn)
            DispatchQueue.main.async {
                self.werkWindAnnotatieBij(coordinate: coordinate, richting: dirDeg, beaufort: beaufort, snelheidKn: speedKn)
            }
        }.resume()
    }

    private var windAnnotatie: WindAnnotation?

    private func werkWindAnnotatieBij(coordinate: CLLocationCoordinate2D, richting: Double, beaufort: Int, snelheidKn: Double) {
        if windAnnotatie == nil {
            let annotatie = WindAnnotation(coordinate: coordinate)
            windAnnotatie = annotatie
            kaart.addAnnotation(annotatie)
        }
        windAnnotatie?.coordinate = coordinate
        windAnnotatie?.directionDegrees = richting
        windAnnotatie?.beaufort = beaufort
        windAnnotatie?.speedKn = snelheidKn
        if let annotatie = windAnnotatie, let view = kaart.view(for: annotatie) as? WindAnnotationView {
            view.update(direction: richting, beaufort: beaufort, speedKn: snelheidKn)
        }
    }

    private func knopenNaarBeaufort(_ knopen: Double) -> Int {
        switch knopen {
        case ..<1: return 0
        case ..<4: return 1
        case ..<7: return 2
        case ..<11: return 3
        case ..<17: return 4
        case ..<22: return 5
        case ..<28: return 6
        case ..<34: return 7
        case ..<41: return 8
        case ..<48: return 9
        case ..<56: return 10
        case ..<64: return 11
        default: return 12
        }
    }
}

extension KaartViewController: LocatieWaarnemer {
    func locatieBijgewerkt(_ locatie: CLLocation) {
        let coordinate = locatie.coordinate
        posities.append(coordinate)

        if posities.count > 1 {
            kaart.removeOverlays(kaart.overlays.filter { $0 is MKPolyline })
            kaart.addOverlay(MKPolyline(coordinates: posities, count: posities.count))
        }

        // Tijdens tracking: volg de positie en zoom per categorie + actuele snelheid.
        // Persoon = strak ingezoomd, vliegtuig = veel groter bereik; sneller = verder uitzoomen.
        if TrackerOpslag.trackingActief {
            let straal = gewensteStraal(voorSnelheid: locatie.speed)
            let regio = MKCoordinateRegion(center: coordinate, latitudinalMeters: straal * 2, longitudinalMeters: straal * 2)
            kaart.setRegion(regio, animated: heeftKaartGecentreerd)
            heeftKaartGecentreerd = true
        } else if !heeftKaartGecentreerd {
            heeftKaartGecentreerd = true
            kaart.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
        }

        werkWindBij(coordinate: coordinate)
    }

    /// Gewenste straal (meter) rond de positie: per categorie een basis- en maxbereik,
    /// meeschalend met de actuele snelheid (toont ongeveer zoveel seconden vooruit).
    private func gewensteStraal(voorSnelheid snelheid: CLLocationSpeed) -> CLLocationDistance {
        let v = max(0, snelheid) // m/s; -1 = ongeldig → 0
        let basis: CLLocationDistance, vooruitSec: Double, maximum: CLLocationDistance
        switch TrackerOpslag.type {
        case .person: (basis, vooruitSec, maximum) = (200, 45, 1500)      // maximale zoom
        case .bike:   (basis, vooruitSec, maximum) = (400, 60, 4000)
        case .car:    (basis, vooruitSec, maximum) = (900, 60, 12000)
        case .boat:   (basis, vooruitSec, maximum) = (1200, 60, 15000)
        case .train:  (basis, vooruitSec, maximum) = (1500, 70, 25000)
        case .plane:  (basis, vooruitSec, maximum) = (6000, 90, 120000)   // veel groter bereik
        case .none:   (basis, vooruitSec, maximum) = (700, 60, 8000)
        }
        return min(maximum, max(basis, v * vooruitSec))
    }
}

extension KaartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is OWMTileOverlay {
            return OWMTileRenderer(tileOverlay: overlay as! MKTileOverlay)
        }
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        }
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let windAnnotation = annotation as? WindAnnotation else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: WindAnnotationView.reuseIdentifier) as? WindAnnotationView
            ?? WindAnnotationView(annotation: windAnnotation, reuseIdentifier: WindAnnotationView.reuseIdentifier)
        view.annotation = windAnnotation
        return view
    }
}
