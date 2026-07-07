import MapKit

/// Luchtvaartlaag (vliegvelden & luchtruim) van OpenAIP — voor categorie
/// Vliegtuig. Vereist een gratis API-sleutel (openaip.net), zelfde bron als
/// op de alltrexx.live-webkaart (OVERLAYS.luchtvaart).
class OpenAIPOverlay: MKTileOverlay {
    static func make(apiKey: String) -> OpenAIPOverlay {
        let overlay = OpenAIPOverlay(urlTemplate: "https://api.tiles.openaip.net/api/data/openaip/{z}/{x}/{y}.png?apiKey=\(apiKey)")
        overlay.canReplaceMapContent = false
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}
