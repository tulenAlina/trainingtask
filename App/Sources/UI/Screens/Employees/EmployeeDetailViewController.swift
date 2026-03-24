import UIKit

final class EmployeeDetailViewController: UIViewController, EmployeesViewControllerDelegate {
    
    weak var delegate: EmployeesViewControllerDelegate?
    
    private var employee: Employee
    private var firstNameLabel = UILabel()
    private var lastNameLabel = UILabel()
    private var surNameLabel = UILabel()
    private var positionLabel = UILabel()
    
    init(employee: Employee) {
        self.employee = employee
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Детали сотрудника"
        
        setupLabels()
        
        view.addSubview(firstNameLabel)
        view.addSubview(lastNameLabel)
        view.addSubview(surNameLabel)
        view.addSubview(positionLabel)
        
        NSLayoutConstraint.activate([
            firstNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 30),
            lastNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            surNameLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: 30),
            surNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionLabel.topAnchor.constraint(equalTo: surNameLabel.bottomAnchor, constant: 30),
            positionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            positionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let changeButton = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(changeTapped))
        navigationItem.rightBarButtonItem = changeButton
    }
    
    func didUpdateEmployee(_ employee: Employee) {
        self.employee = employee
        self.delegate?.didUpdateEmployee(employee)
        updateLabels()
    }
    
    private func updateLabels() {
        firstNameLabel.text = "Имя: \(employee.firstName)"
        lastNameLabel.text = "Фамилия: \(employee.lastName)"
        
        let surNameText: String
        if let surName = employee.surName, !surName.isEmpty {
            surNameText = surName
        } else {
            surNameText = "нет"
        }
        surNameLabel.text = "Отчество: \(surNameText)"
        
        positionLabel.text = "Должность: \(employee.position) "
    }
    
    private func setupLabels() {
        updateLabels()
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        surNameLabel.translatesAutoresizingMaskIntoConstraints = false
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func changeTapped() {
        let editViewController = EditEmployeeViewController(employee)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
}
