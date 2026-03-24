import UIKit

final class EditEmployeeViewController: UIViewController {
    
    weak var delegate: EmployeesViewControllerDelegate?
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var employee: Employee? = nil
    private var firstNameTF: UITextField!
    private var lastNameTF: UITextField!
    private var surNameTF: UITextField!
    private var positionTF: UITextField!
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ employee: Employee) {
        self.employee = employee
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (employee != nil) ? "Редактирование" : "Создание"
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveEmployee))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
        setupTextFields()
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        
        view.addSubview(firstNameTF)
        view.addSubview(lastNameTF)
        view.addSubview(surNameTF)
        view.addSubview(positionTF)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            firstNameTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            firstNameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameTF.topAnchor.constraint(equalTo: firstNameTF.bottomAnchor, constant: 30),
            lastNameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            surNameTF.topAnchor.constraint(equalTo: lastNameTF.bottomAnchor, constant: 30),
            surNameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionTF.topAnchor.constraint(equalTo: surNameTF.bottomAnchor, constant: 30),
            positionTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            positionTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        firstNameTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        lastNameTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        surNameTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        positionTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let employee {
            isEdit = true
            firstNameTF = UITextField.create(text: "\(employee.firstName)", placeholder: "Введите имя", isEdit: isEdit)
            lastNameTF = UITextField.create(text: "\(employee.lastName)", placeholder: "Введите фамилию", isEdit: isEdit)
            surNameTF = UITextField.create(text: "\(employee.surName ?? "")", placeholder: "Введите отчество(если есть)", isEdit: isEdit)
            positionTF = UITextField.create(text: "\(employee.position)", placeholder: "Введите должность", isEdit: isEdit)
        } else {
            firstNameTF = UITextField.create(placeholder: "Введите имя", isEdit: isEdit)
            lastNameTF = UITextField.create(placeholder: "Введите фамилию", isEdit: isEdit)
            surNameTF = UITextField.create(placeholder: "Введите отчество(если есть)", isEdit: isEdit)
            positionTF = UITextField.create(placeholder: "Введите должность", isEdit: isEdit)
        }
    }
    
    @objc private func saveEmployee() {
        let server = ServerManager.shared.currentServer
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        Task {
            do {
                if let employee {
                    var newEmployee = employee
                    newEmployee.firstName = firstNameTF.text?.trimmed ?? ""
                    newEmployee.lastName = lastNameTF.text?.trimmed ?? ""
                    newEmployee.surName = surNameTF.text?.trimmed ?? nil
                    newEmployee.position = positionTF.text?.trimmed ?? ""
                    let savedEmployee = try await server.updateEmployee(newEmployee)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateEmployee(savedEmployee)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let newEmployee = Employee(
                        firstName: firstNameTF.text?.trimmed ?? "",
                        lastName: lastNameTF.text?.trimmed ?? "",
                        surName: surNameTF.text?.trimmed ?? nil,
                        position: positionTF.text?.trimmed ?? ""
                    )
                    let savedEmployee = try await server.createEmployee(newEmployee)
                    DispatchQueue.main.async {
                        self.delegate?.didAddEmployee(savedEmployee)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                self.showAlert("Не удалось сохранить сотрудника")
            }
        }
    }
    
    @objc private func updateSaveButtonState() {
        var isFieldsMatched = false
        if let employee {
            isFieldsMatched = (firstNameTF.text?.trimmed ?? "" == employee.firstName.trimmed) && (lastNameTF.text?.trimmed ?? "" == employee.lastName.trimmed) && (surNameTF.text?.trimmed ?? "" == employee.surName?.trimmed ?? "") && (positionTF.text?.trimmed ?? "" == employee.position.trimmed)
        }
        let isFirstnameFilled = !(firstNameTF.text?.trimmed.isBlank ?? true)
        let isLastnameFilled = !(lastNameTF.text?.trimmed.isBlank ?? true)
        let isPositionFilled = !(positionTF.text?.trimmed.isBlank ?? true)
        
        saveButton.isEnabled = !isFieldsMatched && isFirstnameFilled && isLastnameFilled && isPositionFilled
    }
}
