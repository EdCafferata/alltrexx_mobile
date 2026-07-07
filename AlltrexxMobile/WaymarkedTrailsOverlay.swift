import MapKit

/// Gratis, sleutelloze routelagen van Waymarked Trails — fietsroutes voor
/// categorie Fiets, wandelroutes voor Persoon. Zelfde bron als op de
/// alltrexx.live-webkaart (OVERLAYS.fietsroutes / OVERLAYS.wandelroutes).
enum WaymarkedTrailsSoort: String {
    case fietsen = "cycling"
    case wandelen = "hiking"
}

class WaymarkedTrailsOverlay: MKTileOverlay {
    static func make(_ soort: WaymarkedTrailsSoort) -> WaymarkedTrailsOverlay {
        let overlay = WaymarkedTrailsOverlay(urlTemplate: "https://tile.waymarkedtrails.org/\(soort.rawValue)/{z}/{x}/{y}.png")
        overlay.canReplaceMapContent = false
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
