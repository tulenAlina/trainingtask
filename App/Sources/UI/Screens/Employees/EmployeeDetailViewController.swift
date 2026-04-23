import UIKit

final class EmployeeDetailViewController: BaseViewController {
    var onUpdate: ((Employee) -> Void)
    var onDelete: ((UUID) -> Void)
    
    private let server: Server
    private var employee: Employee
    
    private let fullNameRow = InfoRowView(title: Localized.fullNameLabel)
    private let positionRow = InfoRowView(title: Localized.positionLabel)
    private var deleteButton = ButtonFactory.createDeleteButton()
    
    private lazy var contentScrollView = ScrollableStackView(views: [fullNameRow, positionRow, deleteButton], spacing: 15)
    
    init(employee: Employee, server: Server, onUpdate: @escaping ((Employee) -> Void), onDelete: @escaping ((UUID) -> Void)) {
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
        setupView()
    }
}

private extension EmployeeDetailViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.employeeDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeEmployee))
        setupContentView()
        setupDeleteButton()
        setupActions()
        updateLabels()
    }
    
    func setupContentView() {
        view.addSubview(contentScrollView)
                
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            
            fullNameRow.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            positionRow.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor)
        ])
    }
    
    func setupDeleteButton() {
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    func setupActions() {
        deleteButton.addTarget(self, action: #selector(actionDeleteEmployee), for: .touchUpInside)
    }
    
    func updateLabels() {
        fullNameRow.configure(value: employee.fullName)
        positionRow.configure(value: employee.position)
    }
    
    @objc func actionChangeEmployee() {
        let editViewController = EditEmployeeViewController(employee: employee, server: server, action: .update({[weak self] employee in
            self?.employee = employee
            self?.onUpdate(employee)
            self?.updateLabels()
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    @objc func actionDeleteEmployee() {
        onDelete(employee.id)
        navigationController?.popViewController(animated: true)
    }
}
