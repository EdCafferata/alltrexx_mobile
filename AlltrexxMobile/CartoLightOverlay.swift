import MapKit

/// Gratis, sleutelloze lichte/rustige kaartondergrond van CARTO — vervangt de
/// kaartondergrond voor Vliegtuig en Trein. Zelfde bron als de "licht"-basiskaart
/// op de alltrexx.live-webkaart (BASIS_TILES.licht).
class CartoLightOverlay: MKTileOverlay {
    static func make() -> CartoLightOverlay {
        let overlay = CartoLightOverlay(urlTemplate: "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
