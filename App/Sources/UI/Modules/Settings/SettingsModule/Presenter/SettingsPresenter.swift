import Foundation

final class SettingsPresenter: SettingsModuleInputProtocol {
    weak var view: SettingsViewInputProtocol?
    weak var output: SettingsModuleOutputProtocol?
    private let interactor: SettingsInteractorInputProtocol
    private var router: SettingsRouterInputProtocol
    
    init(interactor: SettingsInteractorInputProtocol, router: SettingsRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - SettingsViewOutputProtocol
extension SettingsPresenter: SettingsViewOutputProtocol {
    func viewDidLoad() {
        configureFields()
    }
    
    func didTapSaveButton(serverUrl: String, maxRecords: String, defaultDaysBetween: String) {
        guard validateSettings(serverUrl: serverUrl, maxRecords: maxRecords, defaultDaysBetween: defaultDaysBetween) else {
            return
        }
        
        guard isFieldsChanged(serverUrl: serverUrl, maxRecords: maxRecords, defaultDaysBetween: defaultDaysBetween) else {
            router.close()
            return
        }
        interactor.updateSettings(serverUrl: serverUrl, maxRecords: maxRecords.cleanedInt, defaultDaysBetween: defaultDaysBetween.cleanedInt)
        router.close()
    }
    
    func textFieldDidChange(textFieldType: SettingsFieldType,text: String?) {
        if text?.isBlank == false {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: true)
        } else {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: false)
        }
    }
}

// MARK: - Private
private extension SettingsPresenter {
    func isFieldsChanged(serverUrl: String, maxRecords: String, defaultDaysBetween: String) -> Bool {
        let settings = interactor.getCurrentSettings()
        let serverUrlChanged = serverUrl != settings.serverUrl
        let maxRecordsChanged = maxRecords != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetween != String(settings.defaultDaysBetween)
        return serverUrlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    func configureFields() {
        let settings = interactor.getCurrentSettings()
        view?.setSettingsFields(
            serverUrl: settings.serverUrl,
            maxRecords: "\(settings.maxRecords)",
            defaultDaysBetween: "\(settings.defaultDaysBetween)"
        )
    }
    
    func validateFields(serverUrl: String, maxRecords: String, defaultDaysBetween: String) -> Bool {
        let fieldsValidity = [serverUrl, maxRecords, defaultDaysBetween].map { $0?.isBlank == false }
        let isValid = fieldsValidity.allSatisfy {$0}
        
        view?.applyValidationResults(fieldsValidity)
        return isValid
    }
    
    func validateSettings(serverUrl: String, maxRecords: String, defaultDaysBetween: String) -> Bool {
        guard validateFields(serverUrl: serverUrl, maxRecords: maxRecords, defaultDaysBetween: defaultDaysBetween) else {
            view?.showAlert(Localized.emptyFields)
            return false
        }
        return true
    }
}
