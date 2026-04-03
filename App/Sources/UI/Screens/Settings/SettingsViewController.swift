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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequiredFields()
        setupUI()
    }
    
    private func setupRequiredFields() {
        requiredFields = [serverUrlTextField, maxRecordsTextField, defaultDaysBetweenTextField]
    }
    
    private func setupUI() {
        setupNavigationTitle(Localized.settings)
        setupTextFields()
        setupLabels()
        setupConstraints()
        addSaveButton(action: #selector(saveSettings))
    }
    
    private func setupTextFields() {
        serverUrlTextField.keyboardType = .URL
        serverUrlTextField.delegate = self
        serverUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        serverUrlTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(serverUrlTextField)
        
        maxRecordsTextField.keyboardType = .numberPad
        maxRecordsTextField.delegate = self
        maxRecordsTextField.translatesAutoresizingMaskIntoConstraints = false
        maxRecordsTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(maxRecordsTextField)
        
        defaultDaysBetweenTextField.keyboardType = .numberPad
        defaultDaysBetweenTextField.delegate = self
        defaultDaysBetweenTextField.translatesAutoresizingMaskIntoConstraints = false
        defaultDaysBetweenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.addSubview(defaultDaysBetweenTextField)
        
        loadCurrentSettings()
    }
    
    private func setupLabels() {
        view.addSubview(serverUrlLabel)
        view.addSubview(maxRecordsLabel)
        view.addSubview(defaultDaysBetweenLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            serverUrlLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            serverUrlLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serverUrlLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            serverUrlTextField.topAnchor.constraint(equalTo: serverUrlLabel.bottomAnchor, constant: 5),
            serverUrlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serverUrlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxRecordsLabel.topAnchor.constraint(equalTo: serverUrlTextField.bottomAnchor, constant: 30),
            maxRecordsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            maxRecordsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxRecordsTextField.topAnchor.constraint(equalTo: maxRecordsLabel.bottomAnchor, constant: 5),
            maxRecordsTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            maxRecordsTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            defaultDaysBetweenLabel.topAnchor.constraint(equalTo: maxRecordsTextField.bottomAnchor, constant: 30),
            defaultDaysBetweenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            defaultDaysBetweenLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            defaultDaysBetweenTextField.topAnchor.constraint(equalTo: defaultDaysBetweenLabel.bottomAnchor, constant: 5),
            defaultDaysBetweenTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            defaultDaysBetweenTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    override func isFieldsChanged() -> Bool {
        let urlChanged = serverUrlTextField.text?.trimmed ?? "" != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text?.trimmed.replacingOccurrences(of: " ", with: "") ?? "" != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text?.trimmed.replacingOccurrences(of: " ", with: "") ?? "" != String(settings.defaultDaysBetween)
        
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
    
    @objc private func saveSettings() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        settings.serverURL = serverUrlTextField.text?.trimmed ?? ""
        settings.maxRecords = Int(maxRecordsTextField.text?.replacingOccurrences(of: " ", with: "") ?? "") ?? 0
        settings.defaultDaysBetween = Int(defaultDaysBetweenTextField.text?.replacingOccurrences(of: " ", with: "") ?? "") ?? 0
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
