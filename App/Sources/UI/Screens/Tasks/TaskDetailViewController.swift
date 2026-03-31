import UIKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    func didDeleteTask(_ task: ProjectTask, at indexPath: IndexPath)
}

final class TaskDetailViewController: UIViewController {
    
    weak var delegate: TasksViewControllerDelegate?
    weak var deleteDelegate: TaskDetailViewControllerDelegate?
    
    private let indexPath: IndexPath
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private let server: Server
    private let settings: SettingsManager
    private let isContextProject: Bool
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var taskNameLabel = UILabel()
    private var projectLabel = UILabel()
    private var workTimeLabel = UILabel()
    private var startDateLabel = UILabel()
    private var endDateLabel = UILabel()
    private var employeeLabel = UILabel()
    private var statusLabel = UILabel()
    private var deleteButton = UIButton()
    
    private let dateFormatter = DateHelper.self
    
    init(indexPath: IndexPath, task: ProjectTask, project: Project?, employee: Employee?, isContextProject: Bool, server: Server, settings: SettingsManager) {
        self.indexPath = indexPath
        self.task = task
        self.project = project
        self.employee = employee
        self.isContextProject = isContextProject
        self.server = server
        self.settings = settings
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
        title = Localized.taskDetails
        setupLabels()
        setupButtons()
        setupConstraints()
        setupNavigationBar()
        setupLoadingIndicator()
    }
    
    private func updateLabels() {
        taskNameLabel.text = "\(Localized.taskLabel) \(task.taskName)"
        projectLabel.text = "\(Localized.projectLabel) \(project?.projectName ?? Localized.unknownProjectLabel)"
        workTimeLabel.text = "\(Localized.hoursLabel) \(task.workTime)"
        
        startDateLabel.text = "\(Localized.startDateLabel) \(dateFormatter.string(from: task.startDate))"
        endDateLabel.text = "\(Localized.endDateLabel) \(dateFormatter.string(from: task.endDate))"
        
        let employeeFIO: String
        if let employee {
            employeeFIO = employee.fullName
        }
        else {
            employeeFIO = Localized.notAssignedLabel
        }
        employeeLabel.text = "\(Localized.employeeLabel) \(employeeFIO)"
        statusLabel.text = "\(Localized.statusLabel) \(task.status.rawValue.localized)"
    }
    
    private func setupLabels() {
        updateLabels()
        taskNameLabel.translatesAutoresizingMaskIntoConstraints = false
        projectLabel.translatesAutoresizingMaskIntoConstraints = false
        workTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
        endDateLabel.translatesAutoresizingMaskIntoConstraints = false
        employeeLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        employeeLabel.numberOfLines = 0
        
        view.addSubview(taskNameLabel)
        view.addSubview(projectLabel)
        view.addSubview(workTimeLabel)
        view.addSubview(startDateLabel)
        view.addSubview(endDateLabel)
        view.addSubview(employeeLabel)
        view.addSubview(statusLabel)
    }
    
    private func setupButtons() {
        deleteButton.setTitle(Localized.delete, for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.borderWidth = 0.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.cornerRadius = 12
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            taskNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            taskNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: 30),
            projectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            workTimeLabel.topAnchor.constraint(equalTo: projectLabel.bottomAnchor, constant: 30),
            workTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startDateLabel.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 30),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 30),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeLabel.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 30),
            employeeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            employeeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: employeeLabel.bottomAnchor, constant: 30),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            
            deleteButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setupNavigationBar() {
        let changeButton = UIBarButtonItem(title: Localized.edit, style: .plain, target: self, action: #selector(changeTapped))
        navigationItem.rightBarButtonItem = changeButton
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
    private func loadRelatedData() async {
        do {
            async let projects = server.fetchProjects()
            async let employees = server.fetchEmployees()
            
            let allProjects = try await projects
            let allEmployees = try await employees
            
            await MainActor.run {
                self.project = allProjects.first { $0.id == task.projectID }
                self.employee = allEmployees.first { $0.id == task.employeeID }
                updateLabels()
            }
        } catch {
            await MainActor.run {
                showAlert(Localized.loadFailed)
            }
        }
    }
    
    @objc private func deleteTapped() {
        deleteDelegate?.didDeleteTask(task, at: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func changeTapped() {
        if let project {
            let editViewController = isContextProject ? EditTaskViewController(task: task, project: project, server: server, settings: settings) : EditTaskViewController(task: task, server: server, settings: settings)
            editViewController.delegate = self
            navigationController?.pushViewController(editViewController, animated: true)
        } else {
            let editViewController = EditTaskViewController(task: task, server: server, settings: settings)
            editViewController.delegate = self
            navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}

extension TaskDetailViewController: TasksViewControllerDelegate {
    func didUpdateTask(_ task: ProjectTask) {
        self.task = task
        self.delegate?.didUpdateTask(task)
        
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        Task {
            await loadRelatedData()
            await MainActor.run {
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
            }
        }
    }
}
