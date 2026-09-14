import AppKit
import CoreLocation
import Foundation

// One short-lived process per request; no resident location tracking.
final class Context: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    let cache = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".cache/zk/context.json")
    var result: [String: Any] = [:]
    var finished = false
    var located = false
    var outstanding = 2

    func finish(_ error: String? = nil) {
        guard !finished else { return }
        finished = true
        manager.stopUpdatingLocation()
        if let error = error { result["error"] = error }
        if !result.isEmpty, let data = try? JSONSerialization.data(withJSONObject: result, options: [.sortedKeys]) {
            if result["latitude"] != nil {
                try? FileManager.default.createDirectory(at: cache.deletingLastPathComponent(), withIntermediateDirectories: true)
                try? data.write(to: cache, options: .atomic)
            }
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write(Data("\n".utf8))
        }
        exit(result["latitude"] == nil ? 1 : 0)
    }

    func start() {
        if !CommandLine.arguments.contains("--refresh"),
           let data = try? Data(contentsOf: cache),
           let saved = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let epoch = saved["observed_epoch"] as? Double,
           Date().timeIntervalSince1970 - epoch >= 0,
           Date().timeIntervalSince1970 - epoch < 600 {
            result = saved
            finish()
            return
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { self.finish("Location/weather lookup timed out") }
        authorize()
    }

    func authorize() {
        switch manager.authorizationStatus {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorized, .authorizedAlways: manager.requestLocation()
        case .denied, .restricted: finish("Allow ZK Context in System Settings → Privacy & Security → Location Services")
        @unknown default: finish("Unknown location authorization status")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined { authorize() }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(error.localizedDescription)
    }

    func completePart() {
        outstanding -= 1
        if outstanding == 0 { finish() }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !located, let location = locations.last,
              location.horizontalAccuracy >= 0,
              abs(location.timestamp.timeIntervalSinceNow) < 600 else { return }
        located = true
        manager.stopUpdatingLocation()
        result = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy_m": location.horizontalAccuracy,
            "observed_epoch": location.timestamp.timeIntervalSince1970,
            "context_observed_at": ISO8601DateFormatter().string(from: location.timestamp),
            "location_source": "macOS Core Location"
        ]
        geocoder.reverseGeocodeLocation(location) { places, _ in
            DispatchQueue.main.async {
                if let place = places?.first {
                    self.result["location"] = [place.locality, place.administrativeArea, place.country]
                        .compactMap { $0 }.reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } }
                        .joined(separator: ", ")
                }
                self.completePart()
            }
        }
        // City-level coordinates suffice for weather; do not transmit a street address.
        let lat = (location.coordinate.latitude * 100).rounded() / 100
        let lon = (location.coordinate.longitude * 100).rounded() / 100
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weather_code&timezone=auto")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let current = json["current"] as? [String: Any] {
                    self.result["temperature_c"] = current["temperature_2m"]
                    self.result["weather_code"] = current["weather_code"]
                    self.result["weather_source"] = "Open-Meteo"
                    if let code = current["weather_code"] as? Int {
                        let descriptions = [0:"Clear", 1:"Mainly clear", 2:"Partly cloudy", 3:"Overcast",
                            45:"Fog", 48:"Depositing rime fog", 51:"Light drizzle", 53:"Drizzle", 55:"Dense drizzle",
                            56:"Light freezing drizzle", 57:"Freezing drizzle", 61:"Light rain", 63:"Rain", 65:"Heavy rain",
                            66:"Light freezing rain", 67:"Heavy freezing rain", 71:"Light snow", 73:"Snow", 75:"Heavy snow",
                            77:"Snow grains", 80:"Light rain showers", 81:"Rain showers", 82:"Violent rain showers",
                            85:"Light snow showers", 86:"Heavy snow showers", 95:"Thunderstorm",
                            96:"Thunderstorm with hail", 99:"Thunderstorm with heavy hail"]
                        self.result["weather"] = descriptions[code] ?? "Weather code \(code)"
                    }
                }
                self.completePart()
            }
        }.resume()
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let context = Context()
DispatchQueue.main.async { context.start() }
app.run()
