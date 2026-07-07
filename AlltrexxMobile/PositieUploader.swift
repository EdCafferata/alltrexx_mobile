import Foundation

/// Verstuurt periodiek (elke 15 minuten) alle nog niet bevestigd verzonden
/// posities uit het `PositieLogboek` naar Alltrexx Live. Vangt zo zowel een
/// kortstondige als een langere verbindingsonderbreking op: bij de eerstvolgende
/// gelegenheid wordt alles wat lokaal is opgebouwd alsnog ingehaald.
enum PositieUploader {
    private static let interval: TimeInterval = 15 * 60
    private static var laatstePoging: Date?

    static func probeerIndienNodig() {
        if let laatste = laatstePoging, Date().timeIntervalSince(laatste) < interval {
            return
        }
        laatstePoging = Date()
        verstuurOnverzonden()
    }

    static func verstuurOnverzonden() {
        guard let token = TrackerOpslag.token else { return }

        for entry in PositieLogboek.onverzonden {
            AlltrexxAPI.stuurPositie(token: token, lat: entry.lat, lon: entry.lon, snelheid: entry.snelheid, koers: entry.koers) { result in
                if case .success = result {
                    PositieLogboek.markeerVerzonden(entry.id)
                }
            }
        }
    }
}
