import Foundation

class Config {
    static let shared = Config()

    private var settings: [String: Any]?

    private init() {
        loadConfig()
    }

    private func loadConfig() {
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path) {
            do {
                settings = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
            } catch {
                print("Error reading config file: \(error)")
            }
        }
    }

    func value(forKey key: String) -> Any? {
        return settings?[key]
    }
}
