import MapKit

/// Gratis, sleutelloze spoorwegenlaag van OpenRailwayMap — voor categorie
/// Trein. Zelfde bron als op de alltrexx.live-webkaart (OVERLAYS.spoorwegen).
class SpoorwegenOverlay: MKTileOverlay {
    static func make() -> SpoorwegenOverlay {
        let overlay = SpoorwegenOverlay(urlTemplate: "https://a.tiles.openrailwaymap.org/standard/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = false
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
