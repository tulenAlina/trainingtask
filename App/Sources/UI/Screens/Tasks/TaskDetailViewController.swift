import UIKit

final class TaskDetailViewController: UIViewController, TasksViewControllerDelegate {
    
    weak var delegate: TasksViewControllerDelegate?
    
    private var task: TaskEntity
    private var project: ProjectEntity?
    private var employee: EmployeeEntity?
    private let server = ServerManager.shared.currentServer
    private let isContextProject: Bool
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var taskNameLabel = UILabel()
    private var projectLabel = UILabel()
    private var workTimeLabel = UILabel()
    private var startDateLabel = UILabel()
    private var endDateLabel = UILabel()
    private var employeeLabel = UILabel()
    private var statusLabel = UILabel()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    init(task: TaskEntity, project: ProjectEntity?, employee: EmployeeEntity?, isContextProject: Bool) {
        self.task = task
        self.project = project
        self.employee = employee
        self.isContextProject = isContextProject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Детали задачи"
        
        setupLabels()
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        
        view.addSubview(taskNameLabel)
        view.addSubview(projectLabel)
        view.addSubview(workTimeLabel)
        view.addSubview(startDateLabel)
        view.addSubview(endDateLabel)
        view.addSubview(employeeLabel)
        view.addSubview(statusLabel)
        view.addSubview(loadingIndicator)
        
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
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let changeButton = UIBarButtonItem(title: "Изменить", style: .plain, target: self, action: #selector(changeTapped))
        navigationItem.rightBarButtonItem = changeButton
    }
    
    func didUpdateTask(_ task: TaskEntity) {
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
    
    private func updateLabels() {
        taskNameLabel.text = "Задача: \(task.taskName)"
        projectLabel.text = "Проект: \(project?.projectName ?? "неизвестный проект")"
        workTimeLabel.text = "Часы: \(task.workTime)"
        
        startDateLabel.text = "Дата начала: \(dateFormatter.string(from: task.startDate))"
        endDateLabel.text = "Дата окончания: \(dateFormatter.string(from: task.endDate))"
        
        let employeeFIO: String
        if let employee {
            employeeFIO = employee.fullName
        }
        else {
            employeeFIO = "не назначен"
        }
        employeeLabel.text = "Сотрудник: \(employeeFIO)"
        statusLabel.text = "Статус: \(task.status.rawValue)"
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
                showAlert("Не удалось загрузить проект или сотрудника")
            }
        }
    }
    
    @objc private func changeTapped() {
        if let project {
            let editViewController = isContextProject ? EditTaskViewController(task, project: project) : EditTaskViewController(task)
            editViewController.delegate = self
            navigationController?.pushViewController(editViewController, animated: true)
        } else {
            let editViewController = EditTaskViewController(task)
            editViewController.delegate = self
            navigationController?.pushViewController(editViewController, animated: true)
        }
    }
}
