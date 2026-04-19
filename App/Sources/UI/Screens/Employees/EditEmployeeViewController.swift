import UIKit

final class EditEmployeeViewController: BaseViewController {
    private let server: Server
    private var employee: Employee?
    private let action: EditEmployeeAction
    
    private var firstNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.firstNamePlaceholder)
    private var lastNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.lastNamePlaceholder)
    private var surNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.surnamePlaceholder)
    private var positionTextField = UIFactory.createDefaultTextField(placeholder: Localized.positionPlaceholder)
    
    private let employeeEditView = EditView()
    
    private let requiredFields: [UITextField]
    
    init(employee: Employee? = nil, server: Server, action: EditEmployeeAction) {
        self.employee = employee
        self.server = server
        self.action = action
        requiredFields = [firstNameTextField, lastNameTextField, positionTextField]
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

extension EditEmployeeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

private extension EditEmployeeViewController {
    func setupView() {
        let title = (employee != nil) ? Localized.editEmployee : Localized.addEmployee
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveEmployee))
        setupEditView()
        setupTextFields()
        setupActions()
    }
    
    func setupEditView() {
        view.addSubview(employeeEditView)
        employeeEditView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            employeeEditView.topAnchor.constraint(equalTo: view.topAnchor),
            employeeEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            employeeEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            employeeEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let formRows: [(String, UIView)] = [
            (labelText: Localized.firstNameLabel, inputView: firstNameTextField),
            (labelText: Localized.lastNameLabel, inputView: lastNameTextField),
            (labelText: Localized.surnameLabel, inputView: surNameTextField),
            (labelText: Localized.positionLabel, inputView: positionTextField)
        ]
        
        employeeEditView.setupForm(rows: formRows)
    }
    
    func setupTextFields() {
        if let employee {
            firstNameTextField.text = (employee.firstName)
            lastNameTextField.text = (employee.lastName)
            surNameTextField.text = (employee.surName.unwrappedOrEmpty)
            positionTextField.text = (employee.position)
        }
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        surNameTextField.delegate = self
        positionTextField.delegate = self
    }
    
    func setupActions() {
        firstNameTextField.addTarget(employeeEditView, action: #selector(employeeEditView.textFieldDidChange), for: .editingChanged)
        lastNameTextField.addTarget(employeeEditView, action: #selector(employeeEditView.textFieldDidChange), for: .editingChanged)
        positionTextField.addTarget(employeeEditView, action: #selector(employeeEditView.textFieldDidChange), for: .editingChanged)
    }
    
    func isFieldsChanged() -> Bool {
        guard let employee else {
            return true
        }
        
        let isFirstNameChanged = firstNameTextField.text.unwrappedOrEmpty.trimmed != employee.firstName.trimmed
        let isLastNameChanged = lastNameTextField.text.unwrappedOrEmpty.trimmed != employee.lastName.trimmed
        let isSurNameChanged = surNameTextField.text.unwrappedOrEmpty.trimmed != employee.surName.unwrappedOrEmpty.trimmed
        let isPositionChanged = positionTextField.text.unwrappedOrEmpty.trimmed != employee.position.trimmed
        return isFirstNameChanged || isLastNameChanged || isSurNameChanged || isPositionChanged
    }
    
    func validateFields(firstNameString: String, lastNameString: String, positionString: String) -> Bool {
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [firstNameString, lastNameString, positionString]
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
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [(UITextField, Bool)] = []
        for i in 0..<requiredFields.count {
            result.append((requiredFields[i], fieldsValidity[i]))
        }
        employeeEditView.applyValidationResults(result)
    }
    
    func createEmployee(_ employee: Employee? = nil) -> Employee {
        let newFirstName = firstNameTextField.text.unwrappedOrEmpty.trimmed
        let newLastName = lastNameTextField.text.unwrappedOrEmpty.trimmed
        let newSurName = surNameTextField.text?.trimmed ?? nil
        let newPosition = positionTextField.text.unwrappedOrEmpty.trimmed
        
        if let employee {
            return Employee(
                id: employee.id,
                firstName: newFirstName,
                lastName: newLastName,
                surName: newSurName,
                position: newPosition,
                tasks: employee.tasks,
                createdAt: employee.createdAt
            )
        } else {
            return Employee(
                firstName: firstNameTextField.text.unwrappedOrEmpty.trimmed,
                lastName: lastNameTextField.text.unwrappedOrEmpty.trimmed,
                surName: surNameTextField.text?.trimmed ?? nil,
                position: positionTextField.text.unwrappedOrEmpty.trimmed
            )
        }
    }
    
    func saveEmployee() async throws -> Employee {
        if let employee {
            let updatedEmployee = createEmployee(employee)
            try await server.updateEmployee(updatedEmployee)
            return updatedEmployee
        } else {
            let createdEmployee = createEmployee()
            try await server.createEmployee(createdEmployee)
            return createdEmployee
        }
    }
    
    @objc func actionSaveEmployee() {
        guard validateFields(
            firstNameString: firstNameTextField.text.unwrappedOrEmpty.trimmed,
            lastNameString: lastNameTextField.text.unwrappedOrEmpty.trimmed,
            positionString: positionTextField.text.unwrappedOrEmpty.trimmed
        ) else {
            showAlert(Localized.emptyFields)
            return
        }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        startLoading()
        Task {
            do {
                let savedEmployee = try await saveEmployee()
                await MainActor.run {
                    switch self.action {
                    case .create(let onCreate):
                        onCreate(savedEmployee)
                    case .update(let onUpdate):
                        onUpdate(savedEmployee)
                    }
                    stopLoading()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    showAlert(Localized.saveFailed)
                    stopLoading()
                }
            }
        }
    }
}
