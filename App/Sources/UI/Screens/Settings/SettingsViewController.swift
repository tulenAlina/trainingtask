import UIKit

final class SettingsViewController: BaseViewController {
    private let settings: SettingsManager = AppDelegate.settings
    
    private let serverUrlLabel = LabelFactory.createSecondaryLabel(text: Localized.serverUrlLabel)
    private let maxRecordsLabel = LabelFactory.createSecondaryLabel(text: Localized.maxRecordsLabel)
    private let defaultDaysBetweenLabel = LabelFactory.createSecondaryLabel(text: Localized.defaultDaysBetweenLabel)
    
    private var serverUrlTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.serverUrlPlaceholder)
    private var maxRecordsTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.maxRecordsPlaceholder)
    private var defaultDaysBetweenTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.defaultDaysBetweenPlaceholder)
    
    private let settingsEditView = ValidatableFormView()
    
    private let requiredFields: [UITextField]
    
    init() {
        requiredFields = [serverUrlTextField, maxRecordsTextField, defaultDaysBetweenTextField]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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

private extension SettingsViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.settings, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveSettings))
        setupTextFields()
        setupEditView()
        setupActions()
    }
    
    func setupTextFields() {
        serverUrlTextField.keyboardType = .URL
        serverUrlTextField.delegate = self
        serverUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        
        maxRecordsTextField.keyboardType = .numberPad
        maxRecordsTextField.delegate = self
        maxRecordsTextField.translatesAutoresizingMaskIntoConstraints = false
        
        defaultDaysBetweenTextField.keyboardType = .numberPad
        defaultDaysBetweenTextField.delegate = self
        defaultDaysBetweenTextField.translatesAutoresizingMaskIntoConstraints = false
        
        loadCurrentSettings()
    }
    
    func setupEditView() {
        view.addSubview(settingsEditView)
        settingsEditView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsEditView.topAnchor.constraint(equalTo: view.topAnchor),
            settingsEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let formRows: [FormRow] = [
            FormRow(labelText: Localized.serverUrlLabel, inputView: serverUrlTextField),
            FormRow(labelText: Localized.maxRecordsLabel, inputView: maxRecordsTextField),
            FormRow(labelText: Localized.defaultDaysBetweenLabel, inputView: defaultDaysBetweenTextField)
        ]
        
        settingsEditView.setupForm(rows: formRows)
    }
    
    func setupActions() {
        serverUrlTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        maxRecordsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        defaultDaysBetweenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    func isFieldsChanged() -> Bool {
        let urlChanged = serverUrlTextField.text.unwrappedOrEmpty.trimmed != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.defaultDaysBetween)
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    func validateFields(serverUrlString: String, maxRecordsString: String, defaultDaysBetweenString: String) -> Bool {
        for text in [serverUrlString, maxRecordsString, defaultDaysBetweenString] {
            if text.isBlank == true {
                return false
            }
        }
        return true
    }
    
    @objc func actionSaveSettings() {
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
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.isBlank == false {
            settingsEditView.applyValidationStyle(sender, isValid: true)
        } else {
            settingsEditView.applyValidationStyle(sender, isValid: false)
        }
    }
}
