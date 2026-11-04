import UIKit

/// Eenmalig introscherm bij de allereerste start: legt kort uit wat de app doet
/// en bereidt de locatietoestemming voor, vóór de typeselectie.
final class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwLayout()
    }

    private func bouwLayout() {
        let logo = UIImageView(image: UIImage(named: "AlltrexxLogo"))
        logo.contentMode = .scaleAspectFit
        logo.layer.cornerRadius = 20
        logo.layer.cornerCurve = .continuous
        logo.layer.masksToBounds = true
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.widthAnchor.constraint(equalToConstant: 96).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 96).isActive = true

        let logoWrapper = UIView()
        logoWrapper.addSubview(logo)
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: logoWrapper.topAnchor),
            logo.bottomAnchor.constraint(equalTo: logoWrapper.bottomAnchor),
            logo.centerXAnchor.constraint(equalTo: logoWrapper.centerXAnchor),
        ])

        let titel = UILabel()
        titel.text = "Welkom bij Alltrexx Mobile"
        let basis = UIFont.systemFont(ofSize: 28, weight: .heavy)
        titel.font = basis.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: 28) } ?? basis
        titel.textAlignment = .center
        titel.numberOfLines = 0

        let punten: [(String, String)] = [
            ("location.fill", "Deel je live positie met alltrexx.live, zodat anderen je op de kaart kunnen volgen."),
            ("bolt.horizontal.circle", "Je positie wordt (bijna) real-time doorgestuurd, ook als de app op de achtergrond draait."),
            ("lock.shield", "Alleen je positie en de naam die je kiest worden gedeeld. Je kunt alles op elk moment verwijderen."),
        ]
        let puntenStack = UIStackView(arrangedSubviews: punten.map { maakPunt(icoon: $0.0, tekst: $0.1) })
        puntenStack.axis = .vertical
        puntenStack.spacing = 16

        let knop = UIButton(configuration: .filled())
        knop.configuration?.title = "Aan de slag"
        knop.configuration?.baseBackgroundColor = .systemGreen
        knop.configuration?.cornerStyle = .large
        knop.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        knop.heightAnchor.constraint(equalToConstant: 56).isActive = true
        knop.addAction(UIAction { [weak self] _ in self?.tikStart() }, for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [logoWrapper, titel, puntenStack, knop])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    private func maakPunt(icoon: String, tekst: String) -> UIView {
        let image = UIImageView(image: UIImage(systemName: icoon))
        image.tintColor = .systemGreen
        image.contentMode = .scaleAspectFit
        image.setContentHuggingPriority(.required, for: .horizontal)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 28).isActive = true

        let label = UILabel()
        label.text = tekst
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0

        let rij = UIStackView(arrangedSubviews: [image, label])
        rij.axis = .horizontal
        rij.spacing = 14
        rij.alignment = .top
        return rij
    }

    private func tikStart() {
        TrackerOpslag.onboardingGezien = true
        view.window?.rootViewController = TypeSelectieViewController()
    }
}
