import CoreLocation

/// Wordt door `LocatieManager` op de hoogte gehouden van elke nieuwe locatie,
/// los van hoe vaak dat daadwerkelijk naar de server wordt verstuurd.
protocol LocatieWaarnemer: AnyObject {
    func locatieBijgewerkt(_ locatie: CLLocation)
}
