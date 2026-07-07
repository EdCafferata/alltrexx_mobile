import Foundation

/// Houdt alle gelogde posities lokaal bij (bestand in Documents), inclusief of
/// ze al bevestigd zijn verzonden — zodat `PositieUploader` weet wat nog moet
/// worden ingehaald, ook na een langere verbindingsonderbreking. Verzonden
/// posities ouder dan een week worden opgeruimd; onverzonden posities blijven
/// hoe oud ook altijd bewaard, tot ze alsnog zijn verstuurd.
enum PositieLogboek {
    private static let bewaarPeriode: TimeInterval = 7 * 24 * 60 * 60

    private static let bestandsURL: URL = {
        let map = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return map.appendingPathComponent("positie-logboek.json")
    }()

    private static var entries: [PositieLogEntry] = laad()

    private static func laad() -> [PositieLogEntry] {
        guard let data = try? Data(contentsOf: bestandsURL) else { return [] }
        return (try? JSONDecoder().decode([PositieLogEntry].self, from: data)) ?? []
    }

    private static func bewaar() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: bestandsURL, options: .atomic)
    }

    static func voegToe(lat: Double, lon: Double, snelheid: Double?, koers: Double?) {
        entries.append(PositieLogEntry(lat: lat, lon: lon, snelheid: snelheid, koers: koers))
        schoonOp()
        bewaar()
    }

    static var onverzonden: [PositieLogEntry] { entries.filter { !$0.verzonden } }

    static func markeerVerzonden(_ id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].verzonden = true
        bewaar()
    }

    private static func schoonOp() {
        let grens = Date().addingTimeInterval(-bewaarPeriode)
        entries.removeAll { $0.verzonden && $0.tijdstip < grens }
    }
}
