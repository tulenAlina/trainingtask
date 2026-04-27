import Foundation

final class SettingsManager {
    private enum DefaultSettings {
        static let serverURL = ""
        static let maxRecords = 50
        static let defaultDaysBetween = 7
    }
    
    private(set) var didFailToLoadConfig = false
    
    var serverURL: String {
        get {
            UserDefaults.standard.string(forKey: UserDefaultsKeys.serverURL).unwrappedOrEmpty
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.serverURL)
        }
    }
    
    var maxRecords: Int {
        get {
            UserDefaults.standard.integer(forKey: UserDefaultsKeys.maxRecords)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.maxRecords)
        }
    }
    
    var defaultDaysBetween: Int {
        get {
            UserDefaults.standard.integer(forKey: UserDefaultsKeys.defaultDaysBetween)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.defaultDaysBetween)
        }
    }
    
    private var config: [String: Any]?
    
    init() {
        loadConfig()
        registerDefaults()
    }
    
    private func loadConfig() {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            didFailToLoadConfig = true
            return
        }
        config = dict
    }
    
    private func registerDefaults() {
        guard let config else {
            return
        }
        let defaultValues: [String: Any] = [
            UserDefaultsKeys.serverURL : config["serverURL"] as? String ?? DefaultSettings.serverURL,
            UserDefaultsKeys.maxRecords : config["maxRecords"] as? Int ?? DefaultSettings.maxRecords,
            UserDefaultsKeys.defaultDaysBetween : config["defaultDaysBetween"] as? Int ?? DefaultSettings.defaultDaysBetween
        ]
        UserDefaults.standard.register(defaults: defaultValues)
    }
}
