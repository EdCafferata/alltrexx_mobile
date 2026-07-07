//
//  OWMLegendView.swift
//  OpenRHNTracker
//
//  Kleine kleurlegenda in de hoek van de kaart voor de actieve OWM laag.
//

import UIKit

/// Kleine legenda-overlay die de kleurschaal van de actieve OWM-laag toont.
class OWMLegendView: UIView {

    private let titleLabel = UILabel()
    private let stackView  = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.65)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        isUserInteractionEnabled = false

        titleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .fill

        let container = UIStackView(arrangedSubviews: [titleLabel, stackView])
        container.axis = .vertical
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
    }

    /// Configureer de legenda voor de gegeven OWM laag.
    func configure(for layer: OWMLayer) {
        titleLabel.text = layer.displayName
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (color, label) in layer.legendItems {
            let row = makeLegendRow(color: color, text: label)
            stackView.addArrangedSubview(row)
        }
    }

    private func makeLegendRow(color: UIColor, text: String) -> UIView {
        let swatch = UIView()
        swatch.backgroundColor = color
        swatch.layer.cornerRadius = 3
        swatch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            swatch.widthAnchor.constraint(equalToConstant: 14),
            swatch.heightAnchor.constraint(equalToConstant: 14)
        ])

        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        lbl.textColor = .white

        let row = UIStackView(arrangedSubviews: [swatch, lbl])
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .center
        return row
    }
}

// MARK: - Kleurschaal per OWM laag

extension OWMLayer {
    /// (kleur, label) paren van laag naar hoog.
    var legendItems: [(UIColor, String)] {
        switch self {
        case .precipitation:
            return [
                (UIColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1), "0.1 mm/u"),
                (UIColor(red: 0.27, green: 0.51, blue: 0.96, alpha: 1), "0.5 mm/u"),
                (UIColor(red: 0.07, green: 0.19, blue: 0.80, alpha: 1), "2 mm/u"),
                (UIColor(red: 0.49, green: 0.07, blue: 0.60, alpha: 1), "10 mm/u"),
                (UIColor(red: 0.85, green: 0.00, blue: 0.00, alpha: 1), "50+ mm/u")
            ]
        case .clouds:
            return [
                (UIColor(white: 1.0, alpha: 0.3), "0%"),
                (UIColor(white: 0.9, alpha: 0.6), "25%"),
                (UIColor(white: 0.7, alpha: 0.8), "50%"),
                (UIColor(white: 0.5, alpha: 0.9), "75%"),
                (UIColor(white: 0.3, alpha: 1.0), "100%")
            ]
        case .wind:
            return [
                (UIColor(red: 0.20, green: 0.80, blue: 0.20, alpha: 1), "0-2 m/s"),
                (UIColor(red: 0.80, green: 0.90, blue: 0.20, alpha: 1), "5 m/s"),
                (UIColor(red: 1.00, green: 0.85, blue: 0.00, alpha: 1), "10 m/s"),
                (UIColor(red: 1.00, green: 0.50, blue: 0.00, alpha: 1), "15 m/s"),
                (UIColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1), "20+ m/s")
            ]
        case .pressure:
            return [
                (UIColor(red: 0.00, green: 0.20, blue: 0.80, alpha: 1), "< 990 hPa"),
                (UIColor(red: 0.00, green: 0.60, blue: 1.00, alpha: 1), "1000 hPa"),
                (UIColor(red: 0.20, green: 0.90, blue: 0.20, alpha: 1), "1010 hPa"),
                (UIColor(red: 1.00, green: 0.85, blue: 0.00, alpha: 1), "1020 hPa"),
                (UIColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1), "> 1030 hPa")
            ]
        case .temperature:
            return [
                (UIColor(red: 0.00, green: 0.20, blue: 0.80, alpha: 1), "< 0°C"),
                (UIColor(red: 0.00, green: 0.70, blue: 0.90, alpha: 1), "10°C"),
                (UIColor(red: 0.20, green: 0.90, blue: 0.20, alpha: 1), "20°C"),
                (UIColor(red: 1.00, green: 0.70, blue: 0.00, alpha: 1), "30°C"),
                (UIColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1), "> 40°C")
            ]
        }
    }
}
