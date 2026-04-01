import UIKit

final class EditEmployeeViewController: BaseFormViewController {
    
    weak var delegate: EmployeesViewControllerDelegate?
    
    private let server: Server
    private var employee: Employee?
    
    private var firstNameTextField = UIFactory.createTextField(placeholder: Localized.firstNamePlaceholder)
    private var lastNameTextField = UIFactory.createTextField(placeholder: Localized.lastNamePlaceholder)
    private var surNameTextField = UIFactory.createTextField(placeholder: Localized.surnamePlaceholder)
    private var positionTextField = UIFactory.createTextField(placeholder: Localized.positionPlaceholder)
    
    private let firstNameLabel = UIFactory.createLabel(text: Localized.firstNameLabel)
    private let lastNameLabel = UIFactory.createLabel(text: Localized.lastNameLabel)
    private let surNameLabel = UIFactory.createLabel(text: Localized.surnameLabel)
    private let positionLabel = UIFactory.createLabel(text: Localized.positionLabel)
    
    init(employee: Employee? = nil, server: Server) {
        self.employee = employee
        self.server = server
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRequiredFields()
    }
    
    private func setupRequiredFields() {
        requiredFields = [firstNameTextField, lastNameTextField, positionTextField]
    }
    
    private func setupUI() {
        setupNavigationTitle((employee != nil) ? Localized.editEmployee : Localized.addEmployee)
        setupTextFieldsAndLabels()
        setupConstraints()
        addSaveButton(action: #selector(saveEmployee))
    }
    
    private func setupTextFieldsAndLabels() {
        
        if let employee {
            firstNameTextField.text = "\(employee.firstName)"
            lastNameTextField.text = "\(employee.lastName)"
            surNameTextField.text = "\(employee.surName ?? "")"
            positionTextField.text = "\(employee.position)"
        }
        
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        positionTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        surNameTextField.delegate = self
        positionTextField.delegate = self
        
        view.addSubview(firstNameLabel)
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameLabel)
        view.addSubview(lastNameTextField)
        view.addSubview(surNameLabel)
        view.addSubview(surNameTextField)
        view.addSubview(positionLabel)
        view.addSubview(positionTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            firstNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            firstNameTextField.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 5),
            firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameLabel.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameTextField.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: 5),
            lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            surNameLabel.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 10),
            surNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            surNameTextField.topAnchor.constraint(equalTo: surNameLabel.bottomAnchor, constant: 5),
            surNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionLabel.topAnchor.constraint(equalTo: surNameTextField.bottomAnchor, constant: 10),
            positionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            positionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionTextField.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 5),
            positionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            positionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func prepareUpdateData(_ employee: Employee) -> Employee {
        var updatedEmployee = employee
        updatedEmployee.firstName = firstNameTextField.text?.trimmed ?? ""
        updatedEmployee.lastName = lastNameTextField.text?.trimmed ?? ""
        updatedEmployee.surName = surNameTextField.text?.trimmed ?? nil
        updatedEmployee.position = positionTextField.text?.trimmed ?? ""
        return updatedEmployee
    }
    
    private func prepareCreateData() -> Employee {
        return Employee(
            firstName: firstNameTextField.text?.trimmed ?? "",
            lastName: lastNameTextField.text?.trimmed ?? "",
            surName: surNameTextField.text?.trimmed ?? nil,
            position: positionTextField.text?.trimmed ?? ""
        )
    }
    
    private func handleSuccess(savedEmployee: Employee) {
        if employee != nil {
            delegate?.didUpdateEmployee(savedEmployee)
        } else {
            delegate?.didAddEmployee(savedEmployee)
        }
        stopLoading()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func performSave() async throws -> Employee {
        if let employee {
            let updatedEmployee = prepareUpdateData(employee)
            return try await server.updateEmployee(updatedEmployee)
        } else {
            let createdEmployee = prepareCreateData()
            return try await server.createEmployee(createdEmployee)
            
        }
    }
    
    override func isFieldsChanged() -> Bool {
        guard let employee = employee else { return true }
        
        let firstNameChanged = firstNameTextField.text?.trimmed ?? "" != employee.firstName.trimmed
        let lastNameChanged = lastNameTextField.text?.trimmed ?? "" != employee.lastName.trimmed
        let surNameChanged = surNameTextField.text?.trimmed ?? "" != employee.surName?.trimmed ?? ""
        let positionChanged = positionTextField.text?.trimmed ?? "" != employee.position.trimmed
        
        return firstNameChanged || lastNameChanged || surNameChanged || positionChanged
    }
    
    @objc private func saveEmployee() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        startLoading()
        Task {
            do {
                let savedEmployee = try await performSave()
                await MainActor.run {
                    handleSuccess(savedEmployee: savedEmployee)
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
