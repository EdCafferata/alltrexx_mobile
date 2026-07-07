import MapKit

/// Gratis, sleutelloze fietsgerichte kaartondergrond van CyclOSM — vervangt de
/// kaartondergrond voor categorie Fiets. Zelfde bron als de "fiets"-basiskaart
/// op de alltrexx.live-webkaart (BASIS_TILES.cyclosm).
class CyclOSMOverlay: MKTileOverlay {
    static func make() -> CyclOSMOverlay {
        let overlay = CyclOSMOverlay(urlTemplate: "https://a.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = true
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
