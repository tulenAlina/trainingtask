import UIKit

final class SettingsViewController: BaseViewController {
    private let settings: SettingsManager
    
    private let serverUrlLabel = UIFactory.createSecondaryLabel(text: Localized.serverUrlLabel)
    private let maxRecordsLabel = UIFactory.createSecondaryLabel(text: Localized.maxRecordsLabel)
    private let defaultDaysBetweenLabel = UIFactory.createSecondaryLabel(text: Localized.defaultDaysBetweenLabel)
    
    private var serverUrlTextField = UIFactory.createDefaultTextField(placeholder: Localized.serverUrlPlaceholder)
    private var maxRecordsTextField = UIFactory.createDefaultTextField(placeholder: Localized.maxRecordsPlaceholder)
    private var defaultDaysBetweenTextField = UIFactory.createDefaultTextField(placeholder: Localized.defaultDaysBetweenPlaceholder)
    
    private let settingsEditView = EditView()
    
    private let requiredFields: [UITextField]
    
    init(settings: SettingsManager) {
        self.settings = settings
        requiredFields = [serverUrlTextField, maxRecordsTextField, defaultDaysBetweenTextField]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationBar(navigationTitle: Localized.settings, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveSettings))
        setupTextFields()
        setupEditView()
    }
    
    private func setupTextFields() {
        serverUrlTextField.keyboardType = .URL
        serverUrlTextField.delegate = self
        serverUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        serverUrlTextField.addTarget(settingsEditView, action: #selector(settingsEditView.textFieldDidChange), for: .editingChanged)
        
        maxRecordsTextField.keyboardType = .numberPad
        maxRecordsTextField.delegate = self
        maxRecordsTextField.translatesAutoresizingMaskIntoConstraints = false
        maxRecordsTextField.addTarget(settingsEditView, action: #selector(settingsEditView.textFieldDidChange), for: .editingChanged)
        
        defaultDaysBetweenTextField.keyboardType = .numberPad
        defaultDaysBetweenTextField.delegate = self
        defaultDaysBetweenTextField.translatesAutoresizingMaskIntoConstraints = false
        defaultDaysBetweenTextField.addTarget(settingsEditView, action: #selector(settingsEditView.textFieldDidChange), for: .editingChanged)
        
        loadCurrentSettings()
    }
    
    private func setupEditView() {
        view.addSubview(settingsEditView)
        settingsEditView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsEditView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let formRows: [(String, UIView)] = [
            (labelText: Localized.serverUrlLabel, inputView: serverUrlTextField),
            (labelText: Localized.maxRecordsLabel, inputView: maxRecordsTextField),
            (labelText: Localized.defaultDaysBetweenLabel, inputView: defaultDaysBetweenTextField)
        ]
        
        settingsEditView.setupForm(rows: formRows)
    }

    private func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    private func isFieldsChanged() -> Bool {
        let urlChanged = serverUrlTextField.text.unwrappedOrEmpty.trimmed != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.defaultDaysBetween)
        
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    private func validateFields(serverUrlString: String, maxRecordsString: String, defaultDaysBetweenString: String) -> Bool {
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [serverUrlString, maxRecordsString, defaultDaysBetweenString]
        {
            if text.isBlank == true {
                fieldsValidity.append(false)
                isValid = false
            } else {
                fieldsValidity.append(true)
            }
        }
        applyValidationResults(fieldsValidity)
        
        return isValid
    }
    
    private func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [(UITextField, Bool)] = []
        for i in 0..<requiredFields.count {
            result.append((requiredFields[i], fieldsValidity[i]))
        }
        settingsEditView.applyValidationResults(result)
    }
    
    @objc private func actionSaveSettings() {
        guard validateFields(
            serverUrlString: serverUrlTextField.text.unwrappedOrEmpty.trimmed,
            maxRecordsString: maxRecordsTextField.text.unwrappedOrEmpty.trimmed,
            defaultDaysBetweenString: defaultDaysBetweenTextField.text.unwrappedOrEmpty.trimmed
        ) else {
            showAlert(Localized.emptyFields)
            return
        }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        settings.serverURL = serverUrlTextField.text.unwrappedOrEmpty.trimmed
        settings.maxRecords = maxRecordsTextField.text.unwrappedOrEmpty.withoutSpaces.cleanedInt
        settings.defaultDaysBetween = defaultDaysBetweenTextField.text.unwrappedOrEmpty.withoutSpaces.cleanedInt
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == maxRecordsTextField || textField == defaultDaysBetweenTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return true
    }
}
