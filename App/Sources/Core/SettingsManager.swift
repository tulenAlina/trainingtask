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
            UserDefaults.standard.string(forKey: UserDefaultsKeys.serverURL) ?? ""
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
            UserDefaultsKeys.serverURL : config?["serverURL"] as? String ?? "",
            UserDefaultsKeys.maxRecords : config?["maxRecords"] as? Int ?? 0,
            UserDefaultsKeys.defaultDaysBetween : config?["defaultDaysBetween"] as? Int ?? 0
        ]
        UserDefaults.standard.register(defaults: defaultValues)
    }
}
