import UIKit
import MapKit

/// Eigen live kaart: toont de positie van dit toestel, de route die deze sessie
/// al is doorgestuurd naar Alltrexx Live, de neerslag-laag van OpenWeatherMap
/// (zelfde als BVK GPX Tracker) en een windpijl op basis van Open-Meteo.
/// De Start/Stop-knop stuurt dezelfde tracking aan als het Status-scherm.
final class KaartViewController: UIViewController {

    private let kaart = MKMapView()
    private let legende = OWMLegendView()
    private let weerKnop = UIButton(configuration: .filled())
    private let startKnop = UIButton(configuration: .filled())

    private var posities: [CLLocationCoordinate2D] = []
    private var heeftKaartGecentreerd = false
    private var owmOverlay: OWMTileOverlay?
    private var laatsteWindOphaal: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwKaart()
        bouwKnoppen()
        werkWeerWeergaveBij()
        LocatieManager.shared.voegWaarnemerToe(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        werkStartKnopBij()
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
        weerKnop.configuration?.title = "🌧 Neerslag"
        weerKnop.configuration?.cornerStyle = .capsule
        weerKnop.addAction(UIAction { [weak self] _ in self?.tikWeer() }, for: .touchUpInside)

        startKnop.configuration?.cornerStyle = .capsule
        startKnop.addAction(UIAction { [weak self] _ in self?.tikStart() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [weerKnop, startKnop])
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

    private func tikWeer() {
        guard let sleutel = OWMSleutel.waarde, !sleutel.isEmpty else {
            vraagOWMSleutel()
            return
        }
        toonNeerslag(!(owmOverlay != nil))
    }

    private func vraagOWMSleutel() {
        let alert = UIAlertController(
            title: "OpenWeatherMap-sleutel",
            message: "Voor de neerslag-laag is een gratis OpenWeatherMap API-sleutel nodig (dezelfde als in BVK GPX Tracker).",
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "API-sleutel" }
        alert.addAction(UIAlertAction(title: "Annuleren", style: .cancel))
        alert.addAction(UIAlertAction(title: "Opslaan", style: .default) { [weak self, weak alert] _ in
            guard let sleutel = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !sleutel.isEmpty else { return }
            OWMSleutel.waarde = sleutel
            self?.toonNeerslag(true)
        })
        present(alert, animated: true)
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
        let aan = owmOverlay != nil
        weerKnop.configuration?.baseBackgroundColor = aan ? .systemBlue : .secondarySystemBackground
        weerKnop.configuration?.baseForegroundColor = aan ? .white : .label
        legende.isHidden = !aan
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

        let urlStr = "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&current=wind_speed_10m,wind_direction_10m&wind_speed_unit=kn"
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

        if !heeftKaartGecentreerd {
            heeftKaartGecentreerd = true
            kaart.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
        }

        werkWindBij(coordinate: coordinate)
    }
}

extension KaartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is OWMTileOverlay {
            return OWMTileRenderer(tileOverlay: overlay as! MKTileOverlay)
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
