import Foundation

final class SettingsManager {
    static let shared = SettingsManager()
    private init() {
        loadConfig()
        registerDefaults()
    }
    private var config: [String: Any]?
    
    var serverURL: String {
        get {
            UserDefaults.standard.string(forKey: "serverURL") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "serverURL")
        }
    }
    
    var maxRecords: Int {
        get {
            UserDefaults.standard.integer(forKey: "maxRecords")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "maxRecords")
        }
    }
    
    var defaultDaysBetween: Int {
        get {
            UserDefaults.standard.integer(forKey: "defaultDaysBetween")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "defaultDaysBetween")
        }
    }
    
    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("config.plist not found")
            config = [:]
            return
        }
        config = dict
    }
    
    private func registerDefaults() {
        let defaultValues: [String: Any] = [
            "serverURL" : config?["serverURL"] as? String ?? "",
            "maxRecords" : config?["maxRecords"] as? Int ?? 0,
            "defaultDaysBetween" : config?["defaultDaysBetween"] as? Int ?? 0
        ]
        UserDefaults.standard.register(defaults: defaultValues)
    }
}
