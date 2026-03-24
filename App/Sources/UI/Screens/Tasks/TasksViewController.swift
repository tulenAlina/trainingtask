import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func didAddTask(_ task: TaskEntity)
    func didUpdateTask(_ task: TaskEntity)
}

extension TasksViewControllerDelegate {
    func didAddTask(_ task: TaskEntity) {}
}

final class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TasksViewControllerDelegate {
    private let project: ProjectEntity?
    private let server = ServerManager.shared.currentServer
    private var tasks: [TaskEntity] = []
    private var projects: [ProjectEntity] = []
    private var employees: [EmployeeEntity] = []
    private let taskTable = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    init() {
        self.project = nil
        super.init(nibName: nil, bundle: nil)
    }
        
    init(project: ProjectEntity) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Задачи"
        taskTable.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        
        view.addSubview(taskTable)
        view.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            taskTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            taskTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            taskTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        taskTable.dataSource = self
        taskTable.delegate = self
        taskTable.refreshControl = refreshControl
        refreshView()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func didAddTask(_ task: TaskEntity) {
        let maxRecords = SettingsManager.shared.maxRecords
        if tasks.count >= maxRecords {
            tasks.removeLast()
            taskTable.deleteRows(at: [IndexPath(row: maxRecords - 1, section: 0)], with: .automatic)
        }
        tasks.insert(task, at: 0)
        taskTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks[index] = task
            taskTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.taskName
        
        if project == nil {
            let projectName = projects.first(where: {$0.id == task.projectID})?.projectName
            cell.detailTextLabel?.text = projectName
        }
        
        switch task.status {
        case .notStarted:
            cell.imageView?.image = UIImage(systemName: "circle")
        case .inProgress:
            cell.imageView?.image = UIImage(systemName: "play.circle")
        case .completed:
            cell.imageView?.image = UIImage(systemName: "checkmark.circle")
        case .postponed:
            cell.imageView?.image = UIImage(systemName: "pause.circle")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _,_,completion in
            self?.loadingIndicator.startAnimating()
            self?.view.isUserInteractionEnabled = false
            let task = self?.tasks[indexPath.row]
            guard let task else {
                completion(false)
                return
            }
            Task {
                do {
                    try await self?.server.deleteTask(task.id)
                    self?.refreshView()
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.loadingIndicator.stopAnimating()
                        self?.view.isUserInteractionEnabled = true
                        completion(false)
                    }
                    self?.showAlert("Не удалось удалить задачу")
                }
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        let currentProject: ProjectEntity?
        var isContextProject = false
        if let project {
            currentProject = project
            isContextProject = true
        } else {
            currentProject = projects.first { $0.id == task.projectID }
        }
        let currentEmployee = employees.first { $0.id == task.employeeID }
        let detailViewController = TaskDetailViewController(task: task, project: currentProject, employee: currentEmployee, isContextProject: isContextProject)
        detailViewController.delegate = self
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func loadTasks() async throws {
        let allTasks = try await server.fetchTasks(projectID: project?.id)
        if project == nil {
            projects = try await server.fetchProjects()
        }
        employees = try await server.fetchEmployees()
        tasks = Array(allTasks.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.taskTable.reloadData()
            self.updateEmptyState()
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func updateEmptyState() {
        if tasks.isEmpty {
            let label = UILabel()
            label.text = "Нет задач"
            label.textAlignment = .center
            label.textColor = .gray
            taskTable.backgroundView = label
        } else {
            taskTable.backgroundView = nil
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadTasks()
                await MainActor.run {
                    refreshControl.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert("Не удалось загрузить задачи")
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editVC: EditTaskViewController
        if let project {
            editVC = EditTaskViewController(project: project)
        } else {
            editVC = EditTaskViewController()
        }
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
}
