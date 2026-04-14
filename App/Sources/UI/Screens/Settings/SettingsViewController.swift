import UIKit

final class SettingsViewController: BaseFormViewController {
    private let settings: SettingsManager
    
    private let serverUrlLabel = UIFactory.createDefaultLabel(text: Localized.serverUrlLabel)
    private let maxRecordsLabel = UIFactory.createDefaultLabel(text: Localized.maxRecordsLabel)
    private let defaultDaysBetweenLabel = UIFactory.createDefaultLabel(text: Localized.defaultDaysBetweenLabel)
    
    private var serverUrlTextField = UIFactory.createDefaultTextField(placeholder: Localized.serverUrlPlaceholder)
    private var maxRecordsTextField = UIFactory.createDefaultTextField(placeholder: Localized.maxRecordsPlaceholder)
    private var defaultDaysBetweenTextField = UIFactory.createDefaultTextField(placeholder: Localized.defaultDaysBetweenPlaceholder)
    
    init(settings: SettingsManager) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
        requiredFields = [serverUrlTextField, maxRecordsTextField, defaultDaysBetweenTextField]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func isFieldsChanged() -> Bool {
        let urlChanged = serverUrlTextField.text.unwrappedOrEmpty.trimmed != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces != String(settings.defaultDaysBetween)
        
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    private func setupUI() {
        setupNavigationBar(navigationTitle: Localized.settings, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveSettings))
        configureTextFields()
        configureFormRows()
        setupForm()
    }
    
    private func configureTextFields() {
        serverUrlTextField.keyboardType = .URL
        serverUrlTextField.delegate = self
        serverUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        serverUrlTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        maxRecordsTextField.keyboardType = .numberPad
        maxRecordsTextField.delegate = self
        maxRecordsTextField.translatesAutoresizingMaskIntoConstraints = false
        maxRecordsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        defaultDaysBetweenTextField.keyboardType = .numberPad
        defaultDaysBetweenTextField.delegate = self
        defaultDaysBetweenTextField.translatesAutoresizingMaskIntoConstraints = false
        defaultDaysBetweenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        loadCurrentSettings()
    }
    
    private func configureFormRows() {
        let serverUrlRow = UIFactory.createVerticalFieldGroup(labelText: Localized.serverUrlLabel, inputView: serverUrlTextField)
        let maxRecordsRow = UIFactory.createVerticalFieldGroup(labelText: Localized.maxRecordsLabel, inputView: maxRecordsTextField)
        let defaultDaysBetweenRow = UIFactory.createVerticalFieldGroup(labelText: Localized.defaultDaysBetweenLabel, inputView: defaultDaysBetweenTextField)
        
        [serverUrlRow, maxRecordsRow, defaultDaysBetweenRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }

    private func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    @objc private func actionSaveSettings() {
        guard validateFields() else { return }
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
