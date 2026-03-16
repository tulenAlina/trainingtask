import UIKit

final class EditEmployeeViewController: UIViewController {
    private var employee: EmployeeEntity? = nil
    private var firstNameTF: UITextField!
    private var lastNameTF: UITextField!
    private var surNameTF: UITextField!
    private var positionTF: UITextField!
    weak var delegate: EmployeesViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ employee: EmployeeEntity) {
        self.employee = employee
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createTextField(_ label: String, _ isEdit: Bool) -> UITextField{
        let textField = UITextField()
        if isEdit {
            textField.text = label
        } else {
            textField.placeholder = label
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func setupTextFields() {
        var isEdit = false
        if let employee {
            isEdit = true
            firstNameTF = createTextField("\(employee.firstName)", isEdit)
            lastNameTF = createTextField("\(employee.lastName)", isEdit)
            surNameTF = createTextField("\(employee.surName ?? "")", isEdit)
            positionTF = createTextField("\(employee.position)", isEdit)
        } else {
            firstNameTF = createTextField("Введите имя", isEdit)
            lastNameTF = createTextField("Введите фамилию", isEdit)
            surNameTF = createTextField("Введите отчество (если есть)", isEdit)
            positionTF = createTextField("Введите должность", isEdit)
        }
    }
    
    @objc private func saveEmployee() {
        let server = ServerManager.shared.currentServer
        Task {
            do {
                if let employee {
                    var newEmployee = employee
                    newEmployee.firstName = firstNameTF.text ?? ""
                    newEmployee.lastName = lastNameTF.text ?? ""
                    newEmployee.surName = surNameTF.text ?? nil
                    newEmployee.position = positionTF.text ?? ""
                    let savedEmployee = try await server.updateEmployee(newEmployee)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateEmployee(savedEmployee)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let newEmployee = EmployeeEntity(
                        firstName: firstNameTF.text ?? "",
                        lastName: lastNameTF.text ?? "",
                        surName: surNameTF.text ?? nil,
                        position: positionTF.text ?? ""
                    )
                    let savedEmployee = try await server.createEmployee(newEmployee)
                    DispatchQueue.main.async {
                        self.delegate?.didAddEmployee(savedEmployee)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print ("Ошибка сохранения")
            }
        }
    }
    
    @objc private func cancellView() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (employee != nil) ? "Редактирование сотрудника" : "Добавление сотрудника"
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveEmployee))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancellView))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        setupTextFields()
        
        view.addSubview(firstNameTF)
        view.addSubview(lastNameTF)
        view.addSubview(surNameTF)
        view.addSubview(positionTF)
        
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
    }
}
