import MapKit

/// NIET MEER IN GEBRUIK (6 nov 2026). CARTO vereist tegenwoordig een API-sleutel:
/// de keyless-endpoint `basemaps.cartocdn.com/light_all` levert nu alleen nog
/// "API KEY REQUIRED"-watermerktegels. De lichte ondergrond voor Vliegtuig en Trein
/// gebruikt daarom `MKMapType.mutedStandard` (zie `KaartViewController`) — Apple's
/// eigen gedempte basiskaart, zonder externe afhankelijkheid of sleutel.
/// Klasse bewust bewaard voor context; nergens meer aangeroepen.
class CartoLightOverlay: MKTileOverlay {
    static func make() -> CartoLightOverlay {
        let overlay = CartoLightOverlay(urlTemplate: "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
