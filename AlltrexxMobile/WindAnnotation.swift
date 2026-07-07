//
//  WindAnnotation.swift
//  OpenBVKTracker
//
//  Toont een windpijl op de kaart op basis van Open-Meteo data.
//  De pijl wijst in de windrichting (waarheen de wind gaat).
//  Kleur gebaseerd op Beaufort-schaal.
//

import MapKit
import UIKit

// MARK: - Annotation

/// MKAnnotation die de windpijl op de kaart representeert.
class WindAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var directionDegrees: Double = 0   // vanwaar de wind komt (meteorologisch)
    var beaufort: Int = 0
    var speedKn: Double = 0

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

// MARK: - AnnotationView

/// Tekent een grote windpijl met Beaufort-kleurcodering.
class WindAnnotationView: MKAnnotationView {

    static let reuseIdentifier = "WindAnnotationView"

    private let arrowSize: CGFloat = 64

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: arrowSize, height: arrowSize)
        backgroundColor = .clear
        isOpaque = false
        centerOffset = .zero
        isUserInteractionEnabled = false
        layer.zPosition = 999
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard let wind = annotation as? WindAnnotation else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let size = rect.width
        let center = CGPoint(x: size / 2, y: size / 2)
        let arrowLen: CGFloat = size * 0.42
        let headLen: CGFloat = size * 0.18
        let headWidth: CGFloat = size * 0.16
        let shaft: CGFloat = size * 0.06

        // Kleur op Beaufort
        let color = beaufortColor(wind.beaufort)

        // Roteer canvas: meteorologische windrichting = vanwaar wind komt
        // Pijl wijst waarheen de wind GAAT (+ 180°)
        let rotRad = CGFloat((wind.directionDegrees + 180.0) * .pi / 180.0)

        ctx.saveGState()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: rotRad)

        // Teken schaduw / halo voor leesbaarheid op elke achtergrond
        ctx.setShadow(offset: .zero, blur: 4, color: UIColor.black.withAlphaComponent(0.6).cgColor)

        // Schacht
        let shaftPath = UIBezierPath()
        shaftPath.move(to: CGPoint(x: -shaft / 2, y: arrowLen))
        shaftPath.addLine(to: CGPoint(x: shaft / 2, y: arrowLen))
        shaftPath.addLine(to: CGPoint(x: shaft / 2, y: -arrowLen + headLen))
        shaftPath.addLine(to: CGPoint(x: -shaft / 2, y: -arrowLen + headLen))
        shaftPath.close()
        color.setFill()
        shaftPath.fill()

        // Pijlpunt
        let headPath = UIBezierPath()
        headPath.move(to: CGPoint(x: 0, y: -arrowLen))
        headPath.addLine(to: CGPoint(x: headWidth / 2, y: -arrowLen + headLen))
        headPath.addLine(to: CGPoint(x: -headWidth / 2, y: -arrowLen + headLen))
        headPath.close()
        color.setFill()
        headPath.fill()

        ctx.restoreGState()

        // Beaufort getal in cirkel in het midden
        let bftStr = "\(wind.beaufort)"
        let circleR: CGFloat = size * 0.18
        let circlePath = UIBezierPath(ovalIn: CGRect(
            x: center.x - circleR, y: center.y - circleR,
            width: circleR * 2, height: circleR * 2))
        color.setFill()
        circlePath.fill()
        UIColor.white.setStroke()
        circlePath.lineWidth = 1.5
        circlePath.stroke()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: circleR * 1.1),
            .foregroundColor: UIColor.white
        ]
        let bftSize = bftStr.size(withAttributes: attrs)
        bftStr.draw(at: CGPoint(
            x: center.x - bftSize.width / 2,
            y: center.y - bftSize.height / 2),
            withAttributes: attrs)

        // Windsnelheid in knoten onder de cirkel
        let knStr = String(format: "%.1f kn", wind.speedKn)
        let knAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: size * 0.13),
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -2.0
        ]
        let knSize = knStr.size(withAttributes: knAttrs)
        knStr.draw(at: CGPoint(
            x: center.x - knSize.width / 2,
            y: center.y + circleR + 2),
            withAttributes: knAttrs)
    }

    /// Update de pijl met nieuwe winddata en herteken.
    func update(direction: Double, beaufort: Int, speedKn: Double) {
        guard let wind = annotation as? WindAnnotation else { return }
        wind.directionDegrees = direction
        wind.beaufort = beaufort
        wind.speedKn = speedKn
        setNeedsDisplay()
    }

    // MARK: - Beaufort kleurschaal

    private func beaufortColor(_ bft: Int) -> UIColor {
        switch bft {
        case 0...1: return UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)   // groen – windstil
        case 2...3: return UIColor(red: 0.4, green: 0.9, blue: 0.2, alpha: 1)   // lichtgroen
        case 4...5: return UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1)  // geel
        case 6...7: return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1)   // oranje
        case 8...9: return UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1)   // rood
        default:    return UIColor(red: 0.6, green: 0.0, blue: 0.8, alpha: 1)   // paars – storm
        }
    }
}
