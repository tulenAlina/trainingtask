import UIKit

protocol EmployeeDetailViewInputProtocol: AnyObject {
    func configureLabels(fio: String, position: String)
}

protocol EmployeeDetailViewOutputProtocol {
    func viewDidLoad()
    func didTapChangeButton()
    func didTapDeleteButton()
}

final class EmployeeDetailViewController: BaseViewController, EmployeeDetailViewInputProtocol {
    var output: EmployeeDetailViewOutputProtocol
    
    private let fullNameRow = InfoRowView(title: Localized.fullNameLabel)
    private let positionRow = InfoRowView(title: Localized.positionLabel)
    private var deleteButton = ButtonFactory.createDeleteButton()
    
    private lazy var contentScrollView = ScrollableStackView(views: [fullNameRow, positionRow, deleteButton], spacing: 15)
    
    init(presenter: EmployeeDetailViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }
    
    func configureLabels(fio: String, position: String) {
        fullNameRow.configure(fio)
        positionRow.configure(position)
    }
}

// MARK: - Private
private extension EmployeeDetailViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.employeeDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeEmployee))
        setupContentView()
        setupDeleteButton()
        setupActions()
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
    
    @objc func actionDeleteEmployee() {
        output.didTapDeleteButton()
    }
    
    @objc func actionChangeEmployee() {
        output.didTapChangeButton()
    }
}
