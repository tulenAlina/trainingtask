import UIKit

//TODO: Добавить валидацию
final class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    private var serverUrlTF = UITextField()
    private var maxRecordsTF = UITextField()
    private var defaultDaysBetweenTF = UITextField()
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == maxRecordsTF || textField == defaultDaysBetweenTF {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    private func setupTextFields() {
        serverUrlTF.placeholder = "Введите url сервера"
        serverUrlTF.keyboardType = .URL
        serverUrlTF.translatesAutoresizingMaskIntoConstraints = false
        
        maxRecordsTF.placeholder = "Введите максимальное количество записей в списках"
        maxRecordsTF.keyboardType = .numberPad
        maxRecordsTF.delegate = self
        maxRecordsTF.translatesAutoresizingMaskIntoConstraints = false
        
        defaultDaysBetweenTF.placeholder = "Введите количество дней между начальной и конечной датами в задаче"
        defaultDaysBetweenTF.keyboardType = .numberPad
        defaultDaysBetweenTF.delegate = self
        defaultDaysBetweenTF.translatesAutoresizingMaskIntoConstraints = false
        
        loadCurrentSettings()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Настройки"
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSettings))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancellView))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupTextFields()
        
        view.addSubview(serverUrlTF)
        view.addSubview(maxRecordsTF)
        view.addSubview(defaultDaysBetweenTF)
        
        NSLayoutConstraint.activate([
            serverUrlTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            serverUrlTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serverUrlTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            maxRecordsTF.topAnchor.constraint(equalTo: serverUrlTF.bottomAnchor, constant: 30),
            maxRecordsTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            maxRecordsTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            defaultDaysBetweenTF.topAnchor.constraint(equalTo: maxRecordsTF.bottomAnchor, constant: 30),
            defaultDaysBetweenTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            defaultDaysBetweenTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        serverUrlTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        maxRecordsTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        defaultDaysBetweenTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
    }
}
