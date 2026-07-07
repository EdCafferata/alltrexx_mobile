import UIKit
import WebKit

/// Toont de live kaart van alltrexx.live (alle trackers, inclusief dit toestel) in een webview.
final class LiveKaartViewController: UIViewController {

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bouwWebView()
        webView.load(URLRequest(url: URL(string: "https://alltrexx.live")!))
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
