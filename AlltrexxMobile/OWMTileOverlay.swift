//
//  OWMTileOverlay.swift
//  AlltrexxMobile
//
//  OpenWeatherMap tile overlay (gratis tier, API key vereist). Overgenomen uit
//  BVK GPX Tracker, zonder de Preferences-koppeling van die app.
//

import MapKit

enum OWMLayer: String, CaseIterable {
    case precipitation = "precipitation_new"
    case clouds        = "clouds_new"
    case wind          = "wind_new"
    case pressure      = "pressure_new"
    case temperature   = "temp_new"

    var displayName: String {
        switch self {
        case .precipitation: return "Neerslag"
        case .clouds:        return "Bewolking"
        case .wind:          return "Wind"
        case .pressure:      return "Luchtdruk"
        case .temperature:   return "Temperatuur"
        }
    }
}

class OWMTileOverlay: MKTileOverlay {

    static func make(layer: OWMLayer, apiKey: String) -> OWMTileOverlay {
        let template = "https://tile.openweathermap.org/map/\(layer.rawValue)/{z}/{x}/{y}.png?appid=\(apiKey)"
        let overlay = OWMTileOverlay(urlTemplate: template)
        overlay.canReplaceMapContent = false
        overlay.minimumZ = 0
        overlay.maximumZ = 22
        overlay.tileSize = CGSize(width: 256, height: 256)
        return overlay
    }
}

/// Custom renderer die OWM tiles 3x tekent zodat de kleuren intenser/zichtbaarder worden.
class OWMTileRenderer: MKTileOverlayRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
        super.draw(mapRect, zoomScale: zoomScale, in: context)
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
