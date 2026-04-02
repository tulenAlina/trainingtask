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
    private var deleteButton = UIButton()
    
    
    private let timeCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        setupButtons()
        setupTimeCard()
        setupConstraints()
        addRightBarButton(title: Localized.edit, action: #selector(changeTask))
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
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textAlignment = .center
        statusLabel.layer.borderWidth = 0.5
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        taskNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        view.addSubview(taskNameLabel)
        view.addSubview(projectTitleLabel)
        view.addSubview(projectLabel)
        view.addSubview(employeeTitleLabel)
        view.addSubview(employeeLabel)
        view.addSubview(statusLabel)
    }
    
    private func setupTimeCard() {
        view.addSubview(timeCard)
        
        timeCard.addSubview(workTimeTitleLabel)
        timeCard.addSubview(workTimeLabel)
        timeCard.addSubview(startDateTitleLabel)
        timeCard.addSubview(startDateLabel)
        timeCard.addSubview(endDateTitleLabel)
        timeCard.addSubview(endDateLabel)
    }
    
    private func setupButtons() {
        deleteButton.setTitle(Localized.delete, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
        
        view.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            taskNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            taskNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.heightAnchor.constraint(equalToConstant: 25),
            statusLabel.widthAnchor.constraint(equalToConstant: 80),
            
            projectTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            projectTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            projectLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 40),
            projectLabel.leadingAnchor.constraint(equalTo: projectTitleLabel.trailingAnchor, constant: 5),
            projectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeTitleLabel.topAnchor.constraint(equalTo: projectLabel.bottomAnchor, constant: 15),
            employeeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            employeeLabel.topAnchor.constraint(equalTo: projectLabel.bottomAnchor, constant: 15),
            employeeLabel.leadingAnchor.constraint(equalTo: employeeTitleLabel.trailingAnchor, constant: 5),
            employeeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            timeCard.topAnchor.constraint(equalTo: employeeLabel.bottomAnchor, constant: 30),
            timeCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            workTimeTitleLabel.topAnchor.constraint(equalTo: timeCard.topAnchor, constant: 20),
            workTimeTitleLabel.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 20),
            
            workTimeLabel.topAnchor.constraint(equalTo: timeCard.topAnchor, constant: 20),
            workTimeLabel.leadingAnchor.constraint(equalTo: workTimeTitleLabel.trailingAnchor, constant: 5),
            workTimeLabel.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor, constant: -20),
            
            startDateTitleLabel.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 15),
            startDateTitleLabel.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 20),
            
            startDateLabel.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 15),
            startDateLabel.leadingAnchor.constraint(equalTo: startDateTitleLabel.trailingAnchor, constant: 5),
            startDateLabel.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor, constant: -20),
            
            endDateTitleLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 15),
            endDateTitleLabel.leadingAnchor.constraint(equalTo: timeCard.leadingAnchor, constant: 20),
            
            endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 15),
            endDateLabel.leadingAnchor.constraint(equalTo: endDateTitleLabel.trailingAnchor, constant: 5),
            endDateLabel.trailingAnchor.constraint(equalTo: timeCard.trailingAnchor, constant: -20),
            endDateLabel.bottomAnchor.constraint(equalTo: timeCard.bottomAnchor, constant: -20),
            
            deleteButton.topAnchor.constraint(equalTo: timeCard.bottomAnchor, constant: 30),
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
    
    private func loadProjectsAndEmployees() async {
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
    
    @objc private func deleteTask() {
        deleteDelegate?.didDeleteTask(task, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func changeTask() {
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
            await loadProjectsAndEmployees()
        }
    }
}
