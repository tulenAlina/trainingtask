import UIKit

final class TaskDetailViewController: BaseViewController {
    weak var updateDelegate: TaskUpdateDelegate?
    weak var deleteDelegate: TaskDeleteDelegate?
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private let isOpenedFromProject: Bool
    
    private var projectTitleLabel = UILabel()
    private var workTimeTitleLabel = UILabel()
    private var startDateTitleLabel = UILabel()
    private var endDateTitleLabel = UILabel()
    private var employeeTitleLabel = UILabel()
    
    private var taskNameLabel = UILabel()
    private var projectLabel = UILabel()
    private var workTimeLabel = UILabel()
    private var startDateLabel = UILabel()
    private var endDateLabel = UILabel()
    private var employeeLabel = UILabel()
    private var statusLabel = UILabel()
    
    private var deleteButton = UIFactory.createDeleteButton()
    
    
    private let timeCard: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 16
        stack.layer.shadowColor = UIColor.black.cgColor
        stack.layer.shadowOpacity = 0.05
        stack.layer.shadowOffset = CGSize(width: 0, height: 2)
        stack.layer.shadowRadius = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(indexPath: IndexPath, task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, server: Server, settings: SettingsManager, updateDelegate: TaskUpdateDelegate, deleteDelegate: TaskDeleteDelegate) {
        self.indexPath = indexPath
        self.task = task
        self.project = project
        self.employee = employee
        self.isOpenedFromProject = isOpenedFromProject
        self.server = server
        self.settings = settings
        self.updateDelegate = updateDelegate
        self.deleteDelegate = deleteDelegate
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
        setupNavigationTitle(Localized.taskDetails)
        setupLabels()
        setupTimeCard()
        setupStackView()
        setupButtons()
        setupRightBarButton(title: Localized.edit, action: #selector(actionChangeTask))
    }
    
    private func setupLabels() {
        updateLabels()
        
        projectTitleLabel.text = Localized.projectLabel
        workTimeTitleLabel.text = Localized.hoursLabel
        startDateTitleLabel.text = Localized.startDateLabel
        endDateTitleLabel.text = Localized.endDateLabel
        employeeTitleLabel.text = Localized.employeeLabel
        
        for titleLabel in [projectTitleLabel, workTimeTitleLabel, startDateTitleLabel, endDateTitleLabel, employeeTitleLabel] {
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.numberOfLines = 0
            titleLabel.setContentHuggingPriority(.required, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        for label in [taskNameLabel, projectLabel, workTimeLabel, startDateLabel, endDateLabel, employeeLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        taskNameLabel.numberOfLines = 10
        projectLabel.numberOfLines = 2
        employeeLabel.numberOfLines = 2
        
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textAlignment = .center
        statusLabel.layer.borderWidth = 0.5
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        statusLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        taskNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    private func setupTimeCard() {
        let workTimeRow = UIStackView(arrangedSubviews: [workTimeTitleLabel, workTimeLabel])
        let startDateRow = UIStackView(arrangedSubviews: [startDateTitleLabel, startDateLabel])
        let endDateRow = UIStackView(arrangedSubviews: [endDateTitleLabel, endDateLabel])
        
        [workTimeRow, startDateRow, endDateRow].forEach { row in
            row.axis = .horizontal
            row.spacing = 5
            row.translatesAutoresizingMaskIntoConstraints = false
            timeCard.addArrangedSubview(row)
        }
        
        view.addSubview(timeCard)
    }
    
    private func setupStackView() {
        let projectRow = UIStackView(arrangedSubviews: [projectTitleLabel, projectLabel])
        let employeeRow = UIStackView(arrangedSubviews: [employeeTitleLabel, employeeLabel])
        
        [projectRow, employeeRow].forEach { row in
            row.axis = .horizontal
            row.spacing = 5
            row.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let taskAndStatusRow = UIStackView(arrangedSubviews: [taskNameLabel, statusLabel])
        taskAndStatusRow.axis = .vertical
        taskAndStatusRow.spacing = 5
        taskAndStatusRow.alignment = .leading
        taskAndStatusRow.translatesAutoresizingMaskIntoConstraints = false
        
        let projectAndEmployeeRow = UIStackView(arrangedSubviews: [projectRow, employeeRow])
        projectAndEmployeeRow.axis = .vertical
        projectAndEmployeeRow.spacing = 15
        projectAndEmployeeRow.translatesAutoresizingMaskIntoConstraints = false
        
        [taskAndStatusRow, projectAndEmployeeRow, timeCard].forEach { row in
            stackView.addArrangedSubview(row)
        }
        
        view.addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupButtons() {
        deleteButton.addTarget(self, action: #selector(actionDeleteTask), for: .touchUpInside)
        
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        taskNameLabel.text = task.taskName
        projectLabel.text = project?.projectName ?? Localized.unknownProjectLabel
        workTimeLabel.text = "\(task.workTime)"
        startDateLabel.text =  DateHelper.string(from: task.startDate)
        endDateLabel.text = DateHelper.string(from: task.endDate)
        employeeLabel.text = employee?.fullName ?? Localized.notAssignedLabel
        statusLabel.text = task.status.rawValue.localized
        
        switch statusLabel.text {
        case TaskStatus.notStarted.rawValue.localized:
            statusLabel.textColor = .red
            statusLabel.layer.borderColor = UIColor.red.cgColor
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        case TaskStatus.inProgress.rawValue.localized:
            statusLabel.textColor = .blue
            statusLabel.layer.borderColor = UIColor.blue.cgColor
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case TaskStatus.completed.rawValue.localized:
            statusLabel.textColor = .green
            statusLabel.layer.borderColor = UIColor.green.cgColor
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        case TaskStatus.postponed.rawValue.localized:
            statusLabel.textColor = .orange
            statusLabel.layer.borderColor = UIColor.orange.cgColor
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        default:
            break
        }
    }
    
    private func reloadTaskDetails() async {
        do {
            async let projects = server.fetchProjects()
            async let employees = server.fetchEmployees()
            
            let allProjects = try await projects
            let allEmployees = try await employees
            
            await MainActor.run {
                project = allProjects.first { $0.id == task.projectID }
                employee = allEmployees.first { $0.id == task.employeeID }
                updateLabels()
                stopLoading()
            }
        } catch {
            await MainActor.run {
                stopLoading()
                showAlert(Localized.loadFailed)
            }
        }
    }
    
    @objc private func actionDeleteTask() {
        deleteDelegate?.didDeleteTask(task, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionChangeTask() {
        if let project {
            let editViewController = isOpenedFromProject ? EditTaskViewController(task: task, project: project, server: server, settings: settings, updateDelegate: self) : EditTaskViewController(task: task, server: server, settings: settings, updateDelegate: self)
            navigationController?.pushViewController(editViewController, animated: true)
        } else {
            let editViewController = EditTaskViewController(task: task, server: server, settings: settings, updateDelegate: self)
            navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}

extension TaskDetailViewController: TaskUpdateDelegate {
    func didUpdateTask(_ task: ProjectTask) {
        self.task = task
        self.updateDelegate?.didUpdateTask(task)
        
        startLoading()
        Task {
            await reloadTaskDetails()
        }
    }
}
