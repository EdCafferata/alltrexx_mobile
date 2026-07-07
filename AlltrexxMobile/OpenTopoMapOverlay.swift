import MapKit

/// Gratis, sleutelloze topografische kaart (hoogtelijnen, paden, wandel-/fietsroutes)
/// van OpenTopoMap — vervangt de kaartondergrond, voor de categorieën Persoon
/// (wandelen) en Fiets.
class OpenTopoMapOverlay: MKTileOverlay {
    static func make() -> OpenTopoMapOverlay {
        let overlay = OpenTopoMapOverlay(urlTemplate: "https://a.tile.opentopomap.org/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.maximumZ = 17
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
