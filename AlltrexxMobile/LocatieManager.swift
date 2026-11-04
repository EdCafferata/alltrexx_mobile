import CoreLocation

/// Vraagt locatietoestemming en logt de positie in `PositieLogboek`, zolang
/// tracking actief is. `PositieUploader` verstuurt dat logboek (inclusief
/// eventuele achterstand) (bijna) real-time naar Alltrexx Live. De logfrequentie
/// en GPS-nauwkeurigheid passen zich aan op je snelheid om de batterij te sparen,
/// en significante-locatiewijzigingen zorgen dat iOS de app na beëindiging weer
/// opstart zodra je beweegt.
final class LocatieManager: NSObject {
    static let shared = LocatieManager()

    private let manager = CLLocationManager()
    private var laatstGelogd: Date?
    private var huidigeLogInterval: TimeInterval = 10
    private var veiligheidsTimer: Timer?

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
        // Laat iOS de app opnieuw opstarten na beëindiging zodra je weer beweegt.
        manager.startMonitoringSignificantLocationChanges()
        startVeiligheidsTimer()
    }

    func stop() {
        actief = false
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
        veiligheidsTimer?.invalidate()
        veiligheidsTimer = nil
    }

    /// Flusht de wachtrij ook als er even geen nieuwe locatie binnenkomt
    /// (bijvoorbeeld weer online terwijl je stilstaat).
    private func startVeiligheidsTimer() {
        veiligheidsTimer?.invalidate()
        veiligheidsTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            PositieUploader.verstuurOnverzonden()
        }
    }

    /// Past GPS-nauwkeurigheid, afstandsfilter en logfrequentie aan op de snelheid:
    /// zuinig als je (vrijwel) stilstaat, vloeiend als je snel beweegt.
    private func pasEnergieprofielAan(snelheidMS: Double) {
        if snelheidMS < 1.0 {
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.distanceFilter = 50
            huidigeLogInterval = 30
        } else if snelheidMS < 8.0 {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 25
            huidigeLogInterval = 10
        } else {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 20
            huidigeLogInterval = 5
        }
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

        let snelheid = locatie.speed >= 0 ? locatie.speed : nil
        pasEnergieprofielAan(snelheidMS: snelheid ?? 0)

        if laatstGelogd == nil || Date().timeIntervalSince(laatstGelogd!) >= huidigeLogInterval {
            laatstGelogd = Date()
            let koers = locatie.course >= 0 ? locatie.course : nil
            let hoogte = locatie.verticalAccuracy >= 0 ? locatie.altitude : nil
            PositieLogboek.voegToe(lat: locatie.coordinate.latitude, lon: locatie.coordinate.longitude, snelheid: snelheid, koers: koers, hoogte: hoogte)
            // (Bijna) real-time: stuur de nieuwe positie meteen door (gedebounced).
            PositieUploader.nieuwePositie()
        }
    }
}
