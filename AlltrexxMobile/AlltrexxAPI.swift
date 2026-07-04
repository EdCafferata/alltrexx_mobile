import Foundation

/// Antwoord van POST /api/sleutel/gratis — bevat het token waarmee dit toestel
/// later zijn positie mag versturen naar POST /api/mobiel/positie.
struct TrackerSleutel: Decodable {
    let id: Int
    let naam: String
    let type: String
    let token: String
}

enum AlltrexxAPIError: Error {
    case ongeldigAntwoord
    case server(String)
}

/// Kleine, gerichte netwerkclient voor de Alltrexx Live backend (alltrexx.live).
enum AlltrexxAPI {
    static let basisURL = URL(string: "https://alltrexx.live")!

    /// Maakt een gratis inlogsleutel (tracker-token) aan voor dit toestel.
    static func maakSleutel(naam: String, type: TrackerType, completion: @escaping (Result<TrackerSleutel, Error>) -> Void) {
        var request = URLRequest(url: basisURL.appendingPathComponent("/api/sleutel/gratis"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["naam": naam, "type": type.rawValue])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let sleutel = try? JSONDecoder().decode(TrackerSleutel.self, from: data) else {
                DispatchQueue.main.async { completion(.failure(AlltrexxAPIError.ongeldigAntwoord)) }
                return
            }
            DispatchQueue.main.async { completion(.success(sleutel)) }
        }.resume()
    }

    /// Stuurt de huidige positie van dit toestel naar de server.
    static func stuurPositie(token: String, lat: Double, lon: Double, snelheid: Double? = nil, koers: Double? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: basisURL.appendingPathComponent("/api/mobiel/positie"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        var body: [String: Any] = ["token": token, "lat": lat, "lon": lon]
        if let snelheid = snelheid { body["snelheid"] = snelheid }
        if let koers = koers { body["koers"] = koers }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                DispatchQueue.main.async { completion(.failure(AlltrexxAPIError.server("onverwachte status"))) }
                return
            }
            DispatchQueue.main.async { completion(.success(())) }
        }.resume()
    }
}
