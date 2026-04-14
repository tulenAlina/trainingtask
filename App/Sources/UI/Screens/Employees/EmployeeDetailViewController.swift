import UIKit

final class EmployeeDetailViewController: BaseViewController {
    var onUpdate: ((Employee) -> Void)
    var onDelete: ((IndexPath) -> Void)
    
    private let server: Server
    private let indexPath: IndexPath
    private var employee: Employee
    
    private var nameLabel = UILabel()
    private var positionLabel = UILabel()
    
    private var nameTitleLabel = UIFactory.createTitleLabel(text: Localized.fullNameLabel)
    private var positionTitleLabel = UIFactory.createTitleLabel(text: Localized.positionLabel)
    
    private var deleteButton = UIFactory.createDeleteButton()
    
    init(indexPath: IndexPath, employee: Employee, server: Server, onUpdate: @escaping ((Employee) -> Void), onDelete: @escaping ((IndexPath) -> Void)) {
        self.indexPath = indexPath
        self.employee = employee
        self.server = server
        self.onUpdate = onUpdate
        self.onDelete = onDelete
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
        setupNavigationBar(navigationTitle: Localized.employeeDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeEmployee))
        setupLabels()
        setupButtons()
    }
    
    private func setupLabels() {
        updateLabels()

        nameLabel.numberOfLines = 5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        positionLabel.numberOfLines = 3
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameTitleLabel)
        view.addSubview(nameLabel)
        view.addSubview(positionTitleLabel)
        view.addSubview(positionLabel)
        
        NSLayoutConstraint.activate([
            nameTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: nameTitleLabel.trailingAnchor, constant: 5),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            positionTitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            positionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            positionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),
            positionLabel.leadingAnchor.constraint(equalTo: positionTitleLabel.trailingAnchor, constant: 5),
            positionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupButtons() {
        deleteButton.addTarget(self, action: #selector(actionDeleteEmployee), for: .touchUpInside)
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        nameLabel.text = employee.fullName
        positionLabel.text = employee.position
    }
    
    @objc private func actionChangeEmployee() {
        let editViewController = EditEmployeeViewController(employee: employee, server: server, action: .update({[weak self] employee in
            self?.employee = employee
            self?.onUpdate(employee)
            self?.updateLabels()
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc private func actionDeleteEmployee() {
        onDelete(indexPath)
        navigationController?.popViewController(animated: true)
    }
}
