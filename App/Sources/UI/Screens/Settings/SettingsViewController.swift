import UIKit

final class SettingsViewController: BaseFormViewController {
    private let settings: SettingsManager
    
    private let serverUrlLabel = UIFactory.createLabel(text: Localized.serverUrlLabel)
    private let maxRecordsLabel = UIFactory.createLabel(text: Localized.maxRecordsLabel)
    private let defaultDaysBetweenLabel = UIFactory.createLabel(text: Localized.defaultDaysBetweenLabel)
    
    private var serverUrlTextField = UIFactory.createTextField(placeholder: Localized.serverUrlPlaceholder)
    private var maxRecordsTextField = UIFactory.createTextField(placeholder: Localized.maxRecordsPlaceholder)
    private var defaultDaysBetweenTextField = UIFactory.createTextField(placeholder: Localized.defaultDaysBetweenPlaceholder)
    
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
        let serverUrlRow = UIFactory.createFormRow(labelText: Localized.serverUrlLabel, inputView: serverUrlTextField)
        let maxRecordsRow = UIFactory.createFormRow(labelText: Localized.maxRecordsLabel, inputView: maxRecordsTextField)
        let defaultDaysBetweenRow = UIFactory.createFormRow(labelText: Localized.defaultDaysBetweenLabel, inputView: defaultDaysBetweenTextField)
        
        [serverUrlRow, maxRecordsRow, defaultDaysBetweenRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }

    private func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    override func isFieldsChanged() -> Bool {
        let urlChanged = serverUrlTextField.text.orEmpty.trimmed != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text.orEmpty.trimmed.replacingOccurrences(of: " ", with: "") != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text.orEmpty.trimmed.replacingOccurrences(of: " ", with: "") != String(settings.defaultDaysBetween)
        
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    @objc private func actionSaveSettings() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        settings.serverURL = serverUrlTextField.text.orEmpty.trimmed
        settings.maxRecords = Int(maxRecordsTextField.text.orEmpty.replacingOccurrences(of: " ", with: "")) ?? 0
        settings.defaultDaysBetween = Int(defaultDaysBetweenTextField.text.orEmpty.replacingOccurrences(of: " ", with: "")) ?? 0
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
