import UIKit

final class TaskDetailViewController: BaseViewController {
    var onUpdate: ((ProjectTask) -> Void)
    var onDelete: ((IndexPath) -> Void)
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private let isOpenedFromProject: Bool
    
    private var taskNameLabel = UIFactory.createTitleLargeLabel()
    private let statusView = StatusView()
    private let timeCardView = TaskTimeCardView()
    private var deleteButton = UIFactory.createDeleteButton()
    
    private lazy var projectRow = InfoRowView(title: Localized.projectLabel)
    private lazy var employeeRow = InfoRowView(title: Localized.employeeLabel)
    private lazy var taskAndStatusRow = UIFactory.createVerticalStackView(views: [taskNameLabel, statusView], spacing: 5)
    private lazy var projectAndEmployeeRow = UIFactory.createVerticalStackView(views: [projectRow, employeeRow], spacing: 15)
    
    private lazy var contentScrollView = ScrollableStackView(views: [taskAndStatusRow, projectAndEmployeeRow, timeCardView, deleteButton], spacing: 30)
    
    init(indexPath: IndexPath, task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, server: Server, settings: SettingsManager, onUpdate: @escaping ((ProjectTask) -> Void), onDelete: @escaping ((IndexPath) -> Void)) {
        self.indexPath = indexPath
        self.task = task
        self.project = project
        self.employee = employee
        self.isOpenedFromProject = isOpenedFromProject
        self.server = server
        self.settings = settings
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
        setupNavigationBar(navigationTitle: Localized.taskDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeTask))
        setupContentView()
        setupDeleteButton()
        updateLabels()
    }
    
    private func setupContentView() {
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

    private func setupDeleteButton() {
        deleteButton.addTarget(self, action: #selector(actionDeleteTask), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        taskNameLabel.text = task.taskName
        projectRow.value = project?.projectName ?? Localized.unknownProjectLabel
        employeeRow.value = employee?.fullName ?? Localized.notAssignedLabel
        statusView.status = task.status
        
        timeCardView.configure(with: task)
    }
    
    @objc private func actionDeleteTask() {
        onDelete(indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionChangeTask() {
        let editModuleViewController = EditTaskBuilder.build(
            task: task,
            project: project,
            isOpenedFromProject: isOpenedFromProject,
            employee: employee,
            server: server,
            settings: settings,
            action: .update {[weak self] task, project, employee in
                self?.task = task
                self?.project = project
                self?.employee = employee
                self?.onUpdate(task)
                self?.updateLabels()
            }
        )
        navigationController?.pushViewController(editModuleViewController, animated: true)
    }
}
