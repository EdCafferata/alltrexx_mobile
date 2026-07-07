import CoreLocation

/// Vraagt locatietoestemming en logt periodiek de positie in `PositieLogboek`,
/// zolang tracking actief is. `PositieUploader` verstuurt dat logboek (inclusief
/// eventuele achterstand) naar Alltrexx Live.
final class LocatieManager: NSObject {
    static let shared = LocatieManager()

    private let manager = CLLocationManager()
    private var laatstGelogd: Date?
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

        if laatstGelogd == nil || Date().timeIntervalSince(laatstGelogd!) >= minimaleInterval {
            laatstGelogd = Date()
            let snelheid = locatie.speed >= 0 ? locatie.speed : nil
            let koers = locatie.course >= 0 ? locatie.course : nil
            PositieLogboek.voegToe(lat: locatie.coordinate.latitude, lon: locatie.coordinate.longitude, snelheid: snelheid, koers: koers)
        }

        PositieUploader.probeerIndienNodig()
    }
}
