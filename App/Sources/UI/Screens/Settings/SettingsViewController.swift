import UIKit

final class SettingsViewController: UIViewController {
    
    private var serverUrlTF: UITextField!
    private var maxRecordsTF: UITextField!
    private var defaultDaysBetweenTF: UITextField!
    private var serverUrlLabel = UILabel()
    private var maxRecordsLabel = UILabel()
    private var defaultDaysBetweenLabel = UILabel()
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Настройки"
        setupTextFields()
        setupLabels()
        setupTapGesture()
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(saveSettings))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancellView))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
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
            
            serverUrlTF.topAnchor.constraint(equalTo: serverUrlLabel.bottomAnchor, constant: 5),
            serverUrlTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serverUrlTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxRecordsLabel.topAnchor.constraint(equalTo: serverUrlTF.bottomAnchor, constant: 30),
            maxRecordsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            maxRecordsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxRecordsTF.topAnchor.constraint(equalTo: maxRecordsLabel.bottomAnchor, constant: 5),
            maxRecordsTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            maxRecordsTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            defaultDaysBetweenLabel.topAnchor.constraint(equalTo: maxRecordsTF.bottomAnchor, constant: 30),
            defaultDaysBetweenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            defaultDaysBetweenLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            defaultDaysBetweenTF.topAnchor.constraint(equalTo: defaultDaysBetweenLabel.bottomAnchor, constant: 5),
            defaultDaysBetweenTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            defaultDaysBetweenTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTextFields() {
        serverUrlTF = UITextField.create(placeholder: "Введите url сервера")
        serverUrlTF.keyboardType = .URL
        serverUrlTF.translatesAutoresizingMaskIntoConstraints = false
        serverUrlTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(serverUrlTF)
        
        maxRecordsTF = UITextField.create(placeholder: "Введите максимальное количество записей в списках")
        maxRecordsTF.keyboardType = .numberPad
        maxRecordsTF.delegate = self
        maxRecordsTF.translatesAutoresizingMaskIntoConstraints = false
        maxRecordsTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(maxRecordsTF)
        
        defaultDaysBetweenTF = UITextField.create(placeholder: "Введите количество дней между начальной и конечной датами в задаче")
        defaultDaysBetweenTF.keyboardType = .numberPad
        defaultDaysBetweenTF.delegate = self
        defaultDaysBetweenTF.translatesAutoresizingMaskIntoConstraints = false
        defaultDaysBetweenTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        view.addSubview(defaultDaysBetweenTF)
        
        loadCurrentSettings()
    }
    
    private func setupLabels() {
        serverUrlLabel.text = "URL сервера:"
        serverUrlLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        serverUrlLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(serverUrlLabel)
        
        maxRecordsLabel.text = "Максимальное количество записей в списках:"
        maxRecordsLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        maxRecordsLabel.numberOfLines = 0
        maxRecordsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(maxRecordsLabel)
        
        defaultDaysBetweenLabel.text = "Количество дней по умолчанию между начальной и конечной датами в задаче:"
        defaultDaysBetweenLabel.font = UIFont.boldSystemFont(ofSize: serverUrlLabel.font.pointSize)
        defaultDaysBetweenLabel.numberOfLines = 0
        defaultDaysBetweenLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(defaultDaysBetweenLabel)
    }
    
    private func loadCurrentSettings() {
        serverUrlTF.text = SettingsManager.shared.serverURL
        maxRecordsTF.text = String(SettingsManager.shared.maxRecords)
        defaultDaysBetweenTF.text = String(SettingsManager.shared.defaultDaysBetween)
    }
    
    @objc private func saveSettings() {
        SettingsManager.shared.serverURL = serverUrlTF.text ?? ""
        SettingsManager.shared.maxRecords = Int(maxRecordsTF.text ?? "") ?? 0
        SettingsManager.shared.defaultDaysBetween = Int(defaultDaysBetweenTF.text ?? "") ?? 0
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancellView() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func updateSaveButtonState() {
        let isURLFilled = !(serverUrlTF.text?.trimmed.isBlank ?? true)
        let isMaxRecordsFilled = !(maxRecordsTF.text?.trimmed.isBlank ?? true)
        let isDefaultDaysBetweenFilled = !(defaultDaysBetweenTF.text?.trimmed.isBlank ?? true)
        
        saveButton.isEnabled = isURLFilled && isMaxRecordsFilled && isDefaultDaysBetweenFilled
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == maxRecordsTF || textField == defaultDaysBetweenTF {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
