import UIKit

protocol TaskDetailModuleOutputProtocol: AnyObject {
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
    func didDeleteTask(at indexPath: IndexPath)
}

final class TaskDetailViewController: BaseViewController, EditTaskModuleOutputProtocol {
    weak var moduleOutput: TaskDetailModuleOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private let isOpenedFromProject: Bool
    
    private var taskNameLabel = LabelFactory.createTitleLargeLabel()
    private let statusView = TaskStatusLabel()
    private let timeCardView = TaskTimeCardView()
    private var deleteButton = ButtonFactory.createDeleteButton()
    
    private lazy var projectRow = InfoRowView(title: Localized.projectLabel)
    private lazy var employeeRow = InfoRowView(title: Localized.employeeLabel)
    private lazy var taskAndStatusRow = StackViewFactory.createVerticalStackView(views: [taskNameLabel, statusView], spacing: 5)
    private lazy var projectAndEmployeeRow = StackViewFactory.createVerticalStackView(views: [projectRow, employeeRow], spacing: 15)
    
    private lazy var contentScrollView = ScrollableStackView(views: [taskAndStatusRow, projectAndEmployeeRow, timeCardView, deleteButton], spacing: 30)
    
    init(indexPath: IndexPath, task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, server: Server, settings: SettingsManager, moduleOutput: TaskDetailModuleOutputProtocol?) {
        self.indexPath = indexPath
        self.task = task
        self.project = project
        self.employee = employee
        self.isOpenedFromProject = isOpenedFromProject
        self.server = server
        self.settings = settings
        self.moduleOutput = moduleOutput
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?) {
        self.task = task
        self.project = project
        self.employee = employee
                
        updateLabels()
        moduleOutput?.didUpdateTask(task, project: project, employee: employee)
    }
    
    func didCreateTask(_ task: ProjectTask) {}
}

private extension TaskDetailViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.taskDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeTask))
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
    
    private func setupActions() {
        deleteButton.addTarget(self, action: #selector(actionDeleteTask), for: .touchUpInside)
    }
    
    func updateLabels() {
        taskNameLabel.text = task.taskName
        projectRow.configure(value: project?.projectName ?? Localized.unknownProjectLabel)
        employeeRow.configure(value: employee?.fullName ?? Localized.notAssignedLabel)
        statusView.configure(with: task.status)
        
        timeCardView.configure(
            workTime: "\(task.workTime)",
            startDate: DateHelper.string(from: task.startDate),
            endDate: DateHelper.string(from: task.endDate)
        )
    }
    
    @objc func actionDeleteTask() {
        moduleOutput?.didDeleteTask(at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionChangeTask() {
        let editModuleViewController = EditTaskModule.build(moduleOutput: self)
        editModuleViewController.input.configureForUpdate(task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee)
        navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}
