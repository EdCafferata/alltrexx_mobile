import UIKit
import MapKit

/// Eigen live kaart: toont de positie van dit toestel plus de route die deze
/// sessie al is doorgestuurd naar Alltrexx Live.
final class KaartViewController: UIViewController {

    private let kaart = MKMapView()
    private var posities: [CLLocationCoordinate2D] = []
    private var heeftKaartGecentreerd = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwKaart()
        LocatieManager.shared.voegWaarnemerToe(self)
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
    }
}

extension KaartViewController: LocatieWaarnemer {
    func locatieBijgewerkt(_ locatie: CLLocation) {
        let coordinate = locatie.coordinate
        posities.append(coordinate)

        if posities.count > 1 {
            kaart.removeOverlays(kaart.overlays)
            kaart.addOverlay(MKPolyline(coordinates: posities, count: posities.count))
        }

        if !heeftKaartGecentreerd {
            heeftKaartGecentreerd = true
            kaart.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: false)
        }
    }
}

extension KaartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 4
        return renderer
    }
}
