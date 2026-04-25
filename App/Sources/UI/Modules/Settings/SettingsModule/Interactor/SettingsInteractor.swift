protocol SettingsInteractorInputProtocol {
    func getCurrentSettings() -> (serverURL: String, maxRecords: Int, defaultDaysBetween: Int)
    func updateSettings(serverURL: String, maxRecords: Int, defaultDaysBetween: Int)
}

protocol SettingsInteractorOutputProtocol: AnyObject {}

final class SettingsInteractor: SettingsInteractorInputProtocol {
    weak var output: SettingsInteractorOutputProtocol?
    
    private let settings: SettingsManager
    
    init(settings: SettingsManager) {
        self.settings = settings
    }
    
    func getCurrentSettings() -> (serverURL: String, maxRecords: Int, defaultDaysBetween: Int) {
        return (settings.serverURL, settings.maxRecords, settings.defaultDaysBetween)
    }
    
    func updateSettings(serverURL: String, maxRecords: Int, defaultDaysBetween: Int) {
        settings.serverURL = serverURL
        settings.maxRecords = maxRecords
        settings.defaultDaysBetween = defaultDaysBetween
    }
}
