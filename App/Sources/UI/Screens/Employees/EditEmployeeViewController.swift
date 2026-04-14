import UIKit

final class EditEmployeeViewController: BaseFormViewController {
    var onUpdate: ((Employee) -> Void)?
    var onCreate: ((Employee) -> Void)?
    
    private let server: Server
    private var employee: Employee?
    
    private var firstNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.firstNamePlaceholder)
    private var lastNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.lastNamePlaceholder)
    private var surNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.surnamePlaceholder)
    private var positionTextField = UIFactory.createDefaultTextField(placeholder: Localized.positionPlaceholder)
    
    private init(employee: Employee? = nil, server: Server) {
        self.employee = employee
        self.server = server
        super.init(nibName: nil, bundle: nil)
        requiredFields = [firstNameTextField, lastNameTextField, positionTextField]
    }
    
    convenience init(employee: Employee? = nil, server: Server, onUpdate: @escaping ((Employee) -> Void)) {
        self.init(employee: employee, server: server)
        self.onUpdate = onUpdate
    }
    
    convenience init(employee: Employee? = nil, server: Server, onCreate: @escaping ((Employee) -> Void)) {
        self.init(employee: employee, server: server)
        self.onCreate = onCreate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func isFieldsChanged() -> Bool {
        guard let employee = employee else { return true }
        
        let isFirstNameChanged = firstNameTextField.text.unwrappedOrEmpty.trimmed != employee.firstName.trimmed
        let isLastNameChanged = lastNameTextField.text.unwrappedOrEmpty.trimmed != employee.lastName.trimmed
        let isSurNameChanged = surNameTextField.text.unwrappedOrEmpty.trimmed != employee.surName.unwrappedOrEmpty.trimmed
        let isPositionChanged = positionTextField.text.unwrappedOrEmpty.trimmed != employee.position.trimmed
        
        return isFirstNameChanged || isLastNameChanged || isSurNameChanged || isPositionChanged
    }
    
    private func setupUI() {
        let title = (employee != nil) ? Localized.editEmployee : Localized.addEmployee
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveEmployee))
        setupTextFields()
        setupFormRows()
        setupForm()
    }
    
    private func setupTextFields() {
        if let employee {
            firstNameTextField.text = (employee.firstName)
            lastNameTextField.text = (employee.lastName)
            surNameTextField.text = (employee.surName.unwrappedOrEmpty)
            positionTextField.text = (employee.position)
        }
        
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        positionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        surNameTextField.delegate = self
        positionTextField.delegate = self
    }
    
    private func setupFormRows() {
        let firstNameRow = UIFactory.createVerticalFieldGroup(labelText: Localized.firstNameLabel, inputView: firstNameTextField)
        let lastNameRow = UIFactory.createVerticalFieldGroup(labelText: Localized.lastNameLabel, inputView: lastNameTextField)
        let surNameRow = UIFactory.createVerticalFieldGroup(labelText: Localized.surnameLabel, inputView: surNameTextField)
        let positionRow = UIFactory.createVerticalFieldGroup(labelText: Localized.positionLabel, inputView: positionTextField)
        
        [firstNameRow, lastNameRow, surNameRow, positionRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }
    
    private func updatedEmployee(_ employee: Employee) -> Employee {
        let newFirstName = firstNameTextField.text.unwrappedOrEmpty.trimmed
        let newLastName = lastNameTextField.text.unwrappedOrEmpty.trimmed
        let newSurName = surNameTextField.text?.trimmed ?? nil
        let newPosition = positionTextField.text.unwrappedOrEmpty.trimmed
        
        let updatedEmployee = Employee(
            id: employee.id,
            firstName: newFirstName,
            lastName: newLastName,
            surName: newSurName,
            position: newPosition,
            tasks: employee.tasks,
            createdAt: employee.createdAt
        )

        return updatedEmployee
    }
    
    private func buildEmployee() -> Employee {
        return Employee(
            firstName: firstNameTextField.text.unwrappedOrEmpty.trimmed,
            lastName: lastNameTextField.text.unwrappedOrEmpty.trimmed,
            surName: surNameTextField.text?.trimmed ?? nil,
            position: positionTextField.text.unwrappedOrEmpty.trimmed
        )
    }
    
    private func saveEmployee() async throws -> Employee {
        if let employee {
            let updatedEmployee = updatedEmployee(employee)
            return try await server.updateEmployee(updatedEmployee)
        } else {
            let createdEmployee = buildEmployee()
            return try await server.createEmployee(createdEmployee)
            
        }
    }
    
    @objc private func actionSaveEmployee() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        startLoading()
        Task {
            do {
                let savedEmployee = try await saveEmployee()
                await MainActor.run {
                    if employee != nil {
                        onUpdate?(savedEmployee)
                    } else {
                        onCreate?(savedEmployee)
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

extension EditEmployeeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
