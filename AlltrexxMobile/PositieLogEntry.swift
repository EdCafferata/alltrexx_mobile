import Foundation

/// Eén gelogde positie, met of deze al bevestigd is verzonden naar de server.
struct PositieLogEntry: Codable, Identifiable {
    let id: UUID
    let tijdstip: Date
    let lat: Double
    let lon: Double
    let snelheid: Double?
    let koers: Double?
    var verzonden: Bool

    init(lat: Double, lon: Double, snelheid: Double?, koers: Double?) {
        self.id = UUID()
        self.tijdstip = Date()
        self.lat = lat
        self.lon = lon
        self.snelheid = snelheid
        self.koers = koers
        self.verzonden = false
    }
}
