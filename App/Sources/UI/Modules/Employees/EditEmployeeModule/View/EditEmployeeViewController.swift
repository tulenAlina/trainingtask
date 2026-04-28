import UIKit

enum EditEmployeeFieldType {
    case firstName
    case lastName
    case surName
    case position
}

protocol EditEmployeeViewInputProtocol: AnyObject {
    var requiredFields: [UITextField] { get }
    
    func setupNavigationBar(title: String)
    func setEmployeeFields(firstName: String, lastName: String, surName: String?, position: String)
    func applyValidationResults(_ fieldsValidity: [Bool])
    func updateValidationStyle(textFieldType: EditEmployeeFieldType, isValid: Bool)
    func startLoading()
    func stopLoading()
    func showAlert(_ message: String)
}

protocol EditEmployeeViewOutputProtocol {
    func viewDidLoad()
    func didTapSaveButton(firstName: String, lastName: String, surName: String?, position: String)
    func textFieldDidChange(textFieldType: EditEmployeeFieldType, text: String?)
}

final class EditEmployeeViewController: BaseViewController, EditEmployeeViewInputProtocol {
    var output: EditEmployeeViewOutputProtocol
    
    var requiredFields: [UITextField] {
        [firstNameTextField, lastNameTextField, positionTextField]
    }
    
    private var firstNameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.firstNamePlaceholder)
    private var lastNameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.lastNamePlaceholder)
    private var surNameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.surnamePlaceholder)
    private var positionTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.positionPlaceholder)
    
    private let employeeEditView = ValidatableFormView()
    
    init(presenter: EditEmployeeViewOutputProtocol) {
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

    func setupNavigationBar(title: String) {
        super.setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveEmployee))
    }
    
    func setEmployeeFields(firstName: String, lastName: String, surName: String?, position: String) {
        firstNameTextField.text = firstName
        lastNameTextField.text = lastName
        surNameTextField.text = surName
        positionTextField.text = position
    }
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [ValidatedField] = []
        for i in 0..<requiredFields.count {
            result.append(ValidatedField(textField: requiredFields[i], isValid: fieldsValidity[i]))
        }
        employeeEditView.applyValidationResults(result)
    }
    
    func updateValidationStyle(textFieldType: EditEmployeeFieldType, isValid: Bool) {
        let textField: UITextField?
            switch textFieldType {
            case .firstName:
                textField = firstNameTextField
            case .lastName:
                textField = lastNameTextField
            case .position:
                textField = positionTextField
            default:
                textField = nil
            }
        guard let textField else { return }
        employeeEditView.applyValidationStyle(textField, isValid: isValid)
    }
}

// MARK: - UITextFieldDelegate
extension EditEmployeeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK: - Private
private extension EditEmployeeViewController {
    func fieldType(for textField: UITextField) -> EditEmployeeFieldType? {
        switch textField {
        case firstNameTextField:
            return .firstName
        case lastNameTextField:
            return .lastName
        case surNameTextField:
            return .surName
        case positionTextField:
            return .position
        default:
            return nil
        }
    }
    
    func setupView() {
        setupEditView()
        setupTextFields()
        setupActions()
    }
    
    func setupEditView() {
        employeeEditView.addRow(labelText: Localized.firstNameLabel, inputView: firstNameTextField)
        employeeEditView.addRow(labelText: Localized.lastNameLabel, inputView: lastNameTextField)
        employeeEditView.addRow(labelText: Localized.surnameLabel, inputView: surNameTextField)
        employeeEditView.addRow(labelText: Localized.positionLabel, inputView: positionTextField)
        
        view.addSubview(employeeEditView)
        
        NSLayoutConstraint.activate([
            employeeEditView.topAnchor.constraint(equalTo: view.topAnchor),
            employeeEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            employeeEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            employeeEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTextFields() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        surNameTextField.delegate = self
        positionTextField.delegate = self
    }
    
    func setupActions() {
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        positionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func actionSaveEmployee() {
        let firstName = firstNameTextField.text.unwrappedOrEmpty.trimmed
        let lastName = lastNameTextField.text.unwrappedOrEmpty.trimmed
        let surName = surNameTextField.text.unwrappedOrEmpty.trimmed
        let position = positionTextField.text.unwrappedOrEmpty.withoutSpaces
        
        output.didTapSaveButton(
            firstName: firstName,
            lastName: lastName,
            surName: surName,
            position: position
        )
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let fieldType = fieldType(for: textField) else {
            return
        }
        output.textFieldDidChange(textFieldType: fieldType, text: textField.text)
    }
}
