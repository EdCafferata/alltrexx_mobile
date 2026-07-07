import CoreLocation

/// Vraagt locatietoestemming en stuurt periodiek de positie door naar Alltrexx Live
/// via `AlltrexxAPI.stuurPositie`, zolang tracking actief is.
final class LocatieManager: NSObject {
    static let shared = LocatieManager()

    private let manager = CLLocationManager()
    private var laatstVerzonden: Date?
    private let minimaleInterval: TimeInterval = 15

    private(set) var actief = false

    private struct ZwakkeWaarnemer {
        weak var waarnemer: LocatieWaarnemer?
    }
    private var waarnemers: [ZwakkeWaarnemer] = []

    func voegWaarnemerToe(_ waarnemer: LocatieWaarnemer) {
        waarnemers.append(ZwakkeWaarnemer(waarnemer: waarnemer))
    }

    func verwijderWaarnemer(_ waarnemer: LocatieWaarnemer) {
        waarnemers.removeAll { $0.waarnemer === waarnemer }
    }

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 25
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func start() {
        guard !actief else { return }
        actief = true
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        actief = false
        manager.stopUpdatingLocation()
    }
}

extension LocatieManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard actief else { return }
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard actief, let locatie = locations.last else { return }

        waarnemers.forEach { $0.waarnemer?.locatieBijgewerkt(locatie) }

        guard let token = TrackerOpslag.token else { return }
        if let laatst = laatstVerzonden, Date().timeIntervalSince(laatst) < minimaleInterval {
            return
        }
        laatstVerzonden = Date()

        let snelheid = locatie.speed >= 0 ? locatie.speed : nil
        let koers = locatie.course >= 0 ? locatie.course : nil

        AlltrexxAPI.stuurPositie(token: token, lat: locatie.coordinate.latitude, lon: locatie.coordinate.longitude, snelheid: snelheid, koers: koers) { _ in }
    }
}
