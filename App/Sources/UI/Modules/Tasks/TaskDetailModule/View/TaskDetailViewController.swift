import UIKit

protocol TaskDetailViewInputProtocol: AnyObject {
    func configureLabels(taskName: String, projectName: String, employeeName: String, status: TaskStatus, workTime: String, startDate: String, endDate: String )
}

protocol TaskDetailViewOutputProtocol {
    func viewDidLoad()
    func didTapChangeButton()
    func didTapDeleteButton()
}

final class TaskDetailViewController: BaseViewController, TaskDetailViewInputProtocol {
    var output: TaskDetailViewOutputProtocol
    
    private var taskNameLabel = LabelFactory.createTitleLargeLabel()
    private let statusView = TaskStatusLabel()
    private let timeCardView = TaskTimeCardView()
    private var deleteButton = ButtonFactory.createDeleteButton()
    
    private lazy var projectRow = InfoRowView(title: Localized.projectLabel)
    private lazy var employeeRow = InfoRowView(title: Localized.employeeLabel)
    private lazy var taskAndStatusRow = StackViewFactory.createVerticalStackView(views: [taskNameLabel, statusView], spacing: 5)
    private lazy var projectAndEmployeeRow = StackViewFactory.createVerticalStackView(views: [projectRow, employeeRow], spacing: 15)
    
    private lazy var contentScrollView = ScrollableStackView(views: [taskAndStatusRow, projectAndEmployeeRow, timeCardView, deleteButton], spacing: 30)
    
    init(presenter: TaskDetailViewOutputProtocol) {
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
    
    func configureLabels(taskName: String, projectName: String, employeeName: String, status: TaskStatus, workTime: String, startDate: String, endDate: String ) {
        taskNameLabel.text = taskName
        projectRow.configure(value: projectName)
        employeeRow.configure(value: employeeName)
        statusView.configure(with: status)
        
        timeCardView.configure(
            workTime: workTime,
            startDate: startDate,
            endDate: endDate
        )
    }
}

// MARK: - Private

private extension TaskDetailViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.taskDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeTask))
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
            contentScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            taskAndStatusRow.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            projectAndEmployeeRow.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor)
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
        deleteButton.addTarget(self, action: #selector(actionDeleteTask), for: .touchUpInside)
    }
    
    @objc func actionDeleteTask() {
        output.didTapDeleteButton()
    }
    
    @objc func actionChangeTask() {
        output.didTapChangeButton()
    }
}
