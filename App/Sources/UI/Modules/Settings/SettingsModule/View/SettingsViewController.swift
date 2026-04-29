import UIKit

enum SettingsFieldType {
    case serverUrl
    case maxRecords
    case defaultDaysBetween
}

protocol SettingsViewInputProtocol: AnyObject {
    var requiredFields: [UITextField] { get }
    
    func setSettingsFields(serverUrl: String, maxRecords: String, defaultDaysBetween: String)
    func applyValidationResults(_ fieldsValidity: [Bool])
    func updateValidationStyle(textFieldType: SettingsFieldType, isValid: Bool)
    func startLoading()
    func stopLoading()
    func showAlert(_ message: String)
}

protocol SettingsViewOutputProtocol {
    func viewDidLoad()
    func didTapSaveButton(serverUrl: String, maxRecords: String, defaultDaysBetween: String)
    func textFieldDidChange(textFieldType: SettingsFieldType, text: String?)
}

final class SettingsViewController: BaseViewController, SettingsViewInputProtocol {
    var output: SettingsViewOutputProtocol
    
    var requiredFields: [UITextField] {
        [serverUrlTextField, maxRecordsTextField, defaultDaysBetweenTextField]
    }
    
    private var serverUrlTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.serverUrlPlaceholder)
    private var maxRecordsTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.maxRecordsPlaceholder)
    private var defaultDaysBetweenTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.defaultDaysBetweenPlaceholder)
    
    private let settingsEditView = ValidatableFormView()
    
    init(presenter: SettingsViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }
    
    func setSettingsFields(serverUrl: String, maxRecords: String, defaultDaysBetween: String) {
        serverUrlTextField.text = serverUrl
        maxRecordsTextField.text = maxRecords
        defaultDaysBetweenTextField.text = defaultDaysBetween
    }
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [ValidatedField] = []
        for i in 0..<requiredFields.count {
            result.append(ValidatedField(textField: requiredFields[i], isValid: fieldsValidity[i]))
        }
        settingsEditView.applyValidationResults(result)
    }
    
    func updateValidationStyle(textFieldType: SettingsFieldType, isValid: Bool) {
        let textField: UITextField?
        switch textFieldType {
            
        case .serverUrl:
            textField = serverUrlTextField
        case .maxRecords:
            textField = maxRecordsTextField
        case .defaultDaysBetween:
            textField = defaultDaysBetweenTextField
        }
        guard let textField else { return }
        settingsEditView.applyValidationStyle(textField, isValid: isValid)
    }
}

// MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - Private
private extension SettingsViewController {
    func fieldType(for textField: UITextField) -> SettingsFieldType? {
        switch textField {
            
        case serverUrlTextField:
            return .serverUrl
        case maxRecordsTextField:
            return .maxRecords
        case defaultDaysBetweenTextField:
            return .defaultDaysBetween
        default:
            return nil
        }
    }
    
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.settings, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveSettings))
        setupEditView()
        setupTextFields()
        setupActions()
    }
    
    func setupEditView() {
        settingsEditView.addRow(labelText: Localized.serverUrlLabel, inputView: serverUrlTextField)
        settingsEditView.addRow(labelText: Localized.maxRecordsLabel, inputView: maxRecordsTextField)
        settingsEditView.addRow(labelText: Localized.defaultDaysBetweenLabel, inputView: defaultDaysBetweenTextField)
        
        view.addSubview(settingsEditView)
        
        NSLayoutConstraint.activate([
            settingsEditView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTextFields() {
        serverUrlTextField.delegate = self
        maxRecordsTextField.delegate = self
        defaultDaysBetweenTextField.delegate = self
    }
    
    func setupActions() {
        serverUrlTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        maxRecordsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        defaultDaysBetweenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func actionSaveSettings() {
        let serverUrl = serverUrlTextField.text.unwrappedOrEmpty.trimmed
        let maxRecords = maxRecordsTextField.text.unwrappedOrEmpty.withoutSpaces
        let defaultDaysBetween = defaultDaysBetweenTextField.text.unwrappedOrEmpty.withoutSpaces
        
        output.didTapSaveButton(
            serverUrl: serverUrl,
            maxRecords: maxRecords,
            defaultDaysBetween: defaultDaysBetween
        )
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let fieldType = fieldType(for: textField) else {
            return
        }
        output.textFieldDidChange(textFieldType: fieldType, text: textField.text)
    }
}
