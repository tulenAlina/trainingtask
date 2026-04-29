protocol SettingsInteractorInputProtocol {
    func getCurrentSettings() -> (serverUrl: String, maxRecords: Int, defaultDaysBetween: Int)
    func updateSettings(serverUrl: String, maxRecords: Int, defaultDaysBetween: Int)
}

protocol SettingsInteractorOutputProtocol: AnyObject {}

final class SettingsInteractor: SettingsInteractorInputProtocol {
    weak var output: SettingsInteractorOutputProtocol?
    
    private let settings: SettingsManager
    
    init(settings: SettingsManager) {
        self.settings = settings
    }
    
    func getCurrentSettings() -> (serverUrl: String, maxRecords: Int, defaultDaysBetween: Int) {
        return (settings.serverUrl, settings.maxRecords, settings.defaultDaysBetween)
    }
    
    func updateSettings(serverUrl: String, maxRecords: Int, defaultDaysBetween: Int) {
        settings.serverUrl = serverUrl
        settings.maxRecords = maxRecords
        settings.defaultDaysBetween = defaultDaysBetween
    }
}
