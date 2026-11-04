import Foundation

/// Stuurt gelogde posities (bijna) real-time door naar Alltrexx Live, en vangt
/// onderbrekingen op: alles wat lokaal in `PositieLogboek` staat en nog niet is
/// bevestigd, wordt bij de eerstvolgende gelegenheid alsnog ingehaald. Zo sta je
/// vrijwel direct op de live kaart in plaats van met minutenlange vertraging.
enum PositieUploader {
    /// Minimale tijd tussen twee verzend-rondes, om een reeks snelle updates te bundelen.
    private static let minimaleTussentijd: TimeInterval = 3
    private static var laatstePoging: Date?
    private static var bezig = false

    /// Door `LocatieManager` aangeroepen zodra er een nieuwe positie is gelogd.
    static func nieuwePositie() {
        if let laatste = laatstePoging, Date().timeIntervalSince(laatste) < minimaleTussentijd {
            return
        }
        laatstePoging = Date()
        verstuurOnverzonden()
    }

    /// Verstuurt alle nog niet bevestigde posities; één ronde tegelijk.
    static func verstuurOnverzonden() {
        guard !bezig, let token = TrackerOpslag.token else { return }
        let wachtrij = PositieLogboek.onverzonden
        guard !wachtrij.isEmpty else { return }
        bezig = true

        let groep = DispatchGroup()
        for entry in wachtrij {
            groep.enter()
            AlltrexxAPI.stuurPositie(token: token, lat: entry.lat, lon: entry.lon, snelheid: entry.snelheid, koers: entry.koers, hoogte: entry.hoogte) { result in
                if case .success = result {
                    PositieLogboek.markeerVerzonden(entry.id)
                }
                groep.leave()
            }
        }
        groep.notify(queue: .main) { bezig = false }
    }
}
