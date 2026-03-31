import UIKit

protocol EmployeeDetailViewControllerDelegate: AnyObject {
    func didDeleteEmployee(_ employee: Employee, at indexPath: IndexPath)
}

final class EmployeeDetailViewController: UIViewController {
    
    weak var delegate: EmployeesViewControllerDelegate?
    weak var deleteDelegate: EmployeeDetailViewControllerDelegate?
    
    private let indexPath: IndexPath
    private let server: Server
    private var employee: Employee
    private var nameLabel = UILabel()
    private var positionLabel = UILabel()
    private var positionTitleLabel = UILabel()
    private var deleteButton = UIButton()
    
    init(indexPath: IndexPath, employee: Employee, server: Server) {
        self.indexPath = indexPath
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
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = Localized.employeeDetails
        setupLabels()
        setupButtons()
        setupConstraints()
        setupNavigationBar()
    }
    
    private func updateLabels() {
        nameLabel.text = employee.fullName
        positionLabel.text = employee.position
    }
    
    private func setupLabels() {
        updateLabels()
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 0
        
        positionTitleLabel.text = Localized.positionLabel
        positionTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        positionTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        positionTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        positionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        view.addSubview(positionTitleLabel)
        view.addSubview(positionLabel)
    }
    
    private func setupButtons() {
        deleteButton.setTitle(Localized.delete, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionTitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            positionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            positionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            positionLabel.leadingAnchor.constraint(equalTo: positionTitleLabel.trailingAnchor, constant: 5),
            positionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            deleteButton.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupNavigationBar() {
        let changeButton = UIBarButtonItem(title: Localized.edit, style: .plain, target: self, action: #selector(changeTapped))
        navigationItem.rightBarButtonItem = changeButton
    }
    
    @objc private func changeTapped() {
        let editViewController = EditEmployeeViewController(employee: employee, server: server)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc private func deleteTapped() {
        deleteDelegate?.didDeleteEmployee(employee, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
}

extension EmployeeDetailViewController: EmployeesViewControllerDelegate {
    func didUpdateEmployee(_ employee: Employee) {
        self.employee = employee
        self.delegate?.didUpdateEmployee(employee)
        updateLabels()
    }
}
