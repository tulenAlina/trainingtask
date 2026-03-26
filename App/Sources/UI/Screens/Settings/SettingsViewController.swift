import UIKit

final class SettingsViewController: UIViewController {
    
    var saveButton: UIBarButtonItem!
    
    private let settings: SettingsManager
    private var serverUrlTextField: UITextField!
    private var maxRecordsTextField: UITextField!
    private var defaultDaysBetweenTextField: UITextField!
    private var serverUrlLabel = UILabel()
    private var maxRecordsLabel = UILabel()
    private var defaultDaysBetweenLabel = UILabel()
    
    init(settings: SettingsManager) {
        self.settings = settings
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
        view.backgroundColor = .white
        title = Localized.Screen.settings.localized
        setupTextFields()
        setupLabels()
        setupTapGesture()
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: Localized.Action.save.localized, style: .done, target: self, action: #selector(saveSettings))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
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
    
    private func setupTextFields() {
        serverUrlTextField = UITextField.create(placeholder: Localized.Placeholder.serverUrl.localized)
        serverUrlTextField.keyboardType = .URL
        serverUrlTextField.translatesAutoresizingMaskIntoConstraints = false
        serverUrlTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(serverUrlTextField)
        
        maxRecordsTextField = UITextField.create(placeholder: Localized.Placeholder.maxRecords.localized)
        maxRecordsTextField.keyboardType = .numberPad
        maxRecordsTextField.delegate = self
        maxRecordsTextField.translatesAutoresizingMaskIntoConstraints = false
        maxRecordsTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(maxRecordsTextField)
        
        defaultDaysBetweenTextField = UITextField.create(placeholder: Localized.Placeholder.defaultDaysBetween.localized)
        defaultDaysBetweenTextField.keyboardType = .numberPad
        defaultDaysBetweenTextField.delegate = self
        defaultDaysBetweenTextField.translatesAutoresizingMaskIntoConstraints = false
        defaultDaysBetweenTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(defaultDaysBetweenTextField)
        
        loadCurrentSettings()
    }
    
    private func setupLabels() {
        serverUrlLabel.text = Localized.Label.serverUrl.localized
        serverUrlLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        serverUrlLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(serverUrlLabel)
        
        maxRecordsLabel.text = Localized.Label.maxRecords.localized
        maxRecordsLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        maxRecordsLabel.numberOfLines = 0
        maxRecordsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maxRecordsLabel)
        
        defaultDaysBetweenLabel.text = Localized.Label.defaultDaysBetween.localized
        defaultDaysBetweenLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        defaultDaysBetweenLabel.numberOfLines = 0
        defaultDaysBetweenLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultDaysBetweenLabel)
    }
    
    private func loadCurrentSettings() {
        serverUrlTextField.text = settings.serverURL
        maxRecordsTextField.text = String(settings.maxRecords)
        defaultDaysBetweenTextField.text = String(settings.defaultDaysBetween)
    }
    
    @objc private func saveSettings() {
        settings.serverURL = serverUrlTextField.text?.trimmed ?? ""
        settings.maxRecords = Int(maxRecordsTextField.text ?? "") ?? 0
        settings.defaultDaysBetween = Int(defaultDaysBetweenTextField.text ?? "") ?? 0
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func updateSaveButtonState() {
        saveButton.isEnabled = isFormValid
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == maxRecordsTextField || textField == defaultDaysBetweenTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}

extension SettingsViewController: FormValidatable {
    var isFieldsChanged: Bool {
        let urlChanged = serverUrlTextField.text?.trimmed ?? "" != settings.serverURL
        let maxRecordsChanged = maxRecordsTextField.text?.trimmed ?? "" != String(settings.maxRecords)
        let defaultDaysBetweenChanged = defaultDaysBetweenTextField.text?.trimmed ?? "" != String(settings.defaultDaysBetween)
        
        return urlChanged || maxRecordsChanged || defaultDaysBetweenChanged
    }
                                                                                   
    var isFormFilled: Bool {
        let isUrlFilled = !(serverUrlTextField.text?.trimmed.isBlank ?? true)
        let isMaxRecordsFilled = !(maxRecordsTextField.text?.trimmed.isBlank ?? true)
        let isDefaultDaysBetweenFilled = !(defaultDaysBetweenTextField.text?.trimmed.isBlank ?? true)
        return isUrlFilled && isMaxRecordsFilled && isDefaultDaysBetweenFilled
    }
}
