import UIKit

final class EditEmployeeViewController: UIViewController {
    
    weak var delegate: EmployeesViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var employee: Employee?
    private var firstNameTextField: UITextField!
    private var lastNameTextField: UITextField!
    private var surNameTextField: UITextField!
    private var positionTextField: UITextField!
    private var cancelButton: UIBarButtonItem!
    private let server = ServerManager.shared.currentServer
    
    init(_ employee: Employee? = nil) {
        self.employee = employee
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
        title = (employee != nil) ? "Редактирование" : "Создание"
        setupTextFields()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveEmployee))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 30),
            lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            surNameTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 30),
            surNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionTextField.topAnchor.constraint(equalTo: surNameTextField.bottomAnchor, constant: 30),
            positionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            positionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let employee {
            isEdit = true
            firstNameTextField = UITextField.create(text: "\(employee.firstName)", placeholder: "Введите имя", isEdit: isEdit)
            lastNameTextField = UITextField.create(text: "\(employee.lastName)", placeholder: "Введите фамилию", isEdit: isEdit)
            surNameTextField = UITextField.create(text: "\(employee.surName ?? "")", placeholder: "Введите отчество(если есть)", isEdit: isEdit)
            positionTextField = UITextField.create(text: "\(employee.position)", placeholder: "Введите должность", isEdit: isEdit)
        } else {
            firstNameTextField = UITextField.create(placeholder: "Введите имя", isEdit: isEdit)
            lastNameTextField = UITextField.create(placeholder: "Введите фамилию", isEdit: isEdit)
            surNameTextField = UITextField.create(placeholder: "Введите отчество(если есть)", isEdit: isEdit)
            positionTextField = UITextField.create(placeholder: "Введите должность", isEdit: isEdit)
        }
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(surNameTextField)
        view.addSubview(positionTextField)
        
        
        firstNameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        surNameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        positionTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
    }
    
    private func prepareUpdateData() -> Employee {
        var updatedEmployee = employee!
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
        self.loadingIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        self.saveButton.isEnabled = true
        self.navigationController?.popViewController(animated: true)
    }
    
    private func performSave() async throws -> Employee {
        if employee != nil {
            let updatedEmployee = prepareUpdateData()
            return try await server.updateEmployee(updatedEmployee)
        } else {
            let createdEmployee = prepareCreateData()
            return try await server.createEmployee(createdEmployee)
            
        }
    }
    
    @objc private func saveEmployee() {
        startLoading()
        Task {
            do {
                let savedEmployee = try await performSave()
                DispatchQueue.main.async {
                    self.handleSuccess(savedEmployee: savedEmployee)
                }
            } catch {
                await MainActor.run {
                    self.showAlert("Не удалось сохранить сотрудника")
                }
            }
        }
    }
    
    @objc private func updateSaveButtonState() {
        saveButton.isEnabled = isFormValid
    }
}

extension EditEmployeeViewController: FormValidatable {
    var isFieldsChanged: Bool {
        guard let employee = employee else { return true }
        
        let firstNameChanged = firstNameTextField.text?.trimmed ?? "" != employee.firstName.trimmed
        let lastNameChanged = lastNameTextField.text?.trimmed ?? "" != employee.lastName.trimmed
        let surNameChanged = surNameTextField.text?.trimmed ?? "" != employee.surName?.trimmed ?? ""
        let positionChanged = positionTextField.text?.trimmed ?? "" != employee.position.trimmed
        
        return firstNameChanged || lastNameChanged || surNameChanged || positionChanged
    }
                                                                                   
    var isFormFilled: Bool {
        let isFirstnameFilled = !(firstNameTextField.text?.trimmed.isBlank ?? true)
        let isLastnameFilled = !(lastNameTextField.text?.trimmed.isBlank ?? true)
        let isPositionFilled = !(positionTextField.text?.trimmed.isBlank ?? true)
        return isFirstnameFilled && isLastnameFilled && isPositionFilled
    }
}
