import UIKit
import WebKit

/// Toont de live kaart van alltrexx.live (alle trackers, inclusief dit toestel) in een webview.
final class LiveKaartViewController: UIViewController {

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwWebView()
        // Geef het eigen tracker-type mee, zodat de live kaart meteen de bijbehorende
        // kaartlaag/opties kiest (persoon → wandelkaart, boot → zeekaart, enz.).
        var urlStr = "https://alltrexx.live"
        if let type = TrackerOpslag.type {
            urlStr += "/?laag=\(type.webPreset)&types=\(type.rawValue)"
        }
        // Alleen voor store-screenshots (startargument `-screenshot-centrum "lat,lon,z"`):
        // vaste kaartuitsnede i.p.v. de eigen locatie. Zonder argument geen effect.
        if let centrum = UserDefaults.standard.string(forKey: "screenshot-centrum") {
            let d = centrum.split(separator: ",")
            if d.count == 3 {
                urlStr += (urlStr.contains("?") ? "&" : "/?") + "lat=\(d[0])&lon=\(d[1])&z=\(d[2])"
            }
        }
        webView.load(URLRequest(url: URL(string: urlStr)!))
    }

    private func bouwWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
