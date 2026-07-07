import MapKit

/// Gratis, sleutelloze overlay met vaarwegmarkeringen (boeien, vuurtorens,
/// dieptelijnen) van OpenSeaMap — getekend bovenop de gewone kaart, voor de
/// categorie Boot.
class OpenSeaMapOverlay: MKTileOverlay {
    static func make() -> OpenSeaMapOverlay {
        let overlay = OpenSeaMapOverlay(urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = false
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
