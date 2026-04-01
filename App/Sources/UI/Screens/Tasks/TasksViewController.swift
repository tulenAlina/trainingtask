import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func didAddTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask)
}

extension TasksViewControllerDelegate {
    func didAddTask(_ task: ProjectTask) {}
}

final class TasksViewController: BaseViewController {
    let settings: SettingsManager
    let tableView = UITableView()
    
    private let project: Project?
    private let server: Server
    private var tasks: [ProjectTask] = []
    private var projects: [Project] = []
    private var employees: [Employee] = []
    private let refreshControl = UIRefreshControl()
        
    init(project: Project? = nil, server: Server, settings: SettingsManager) {
        self.project = project
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
        refreshView()
    }
    
    private func setupUI() {
        setupNavigationTitle(Localized.tasks)
        setupTableView()
        setupConstraints()
        addRightBarButton(systemItem: .add, action: #selector(addTapped))
        startLoading()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func loadTasks() async throws {
        async let allTasks = try await server.fetchTasks(projectID: project?.id)
        async let allEmployees = server.fetchEmployees()
        if project == nil {
            async let allProjects = server.fetchProjects()
            let (tasks, projects, employees) = try await (allTasks, allProjects, allEmployees)
            self.projects = projects
            self.employees = employees
            self.tasks = Array(tasks.prefix(settings.maxRecords))
        } else {
            let (tasks, employees) = try await (allTasks, allEmployees)
            self.employees = employees
            self.tasks = Array(tasks.prefix(settings.maxRecords))
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
            self.stopLoading()
        }
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let task = self.tasks[indexPath.row]

        Task {
            do {
                try await self.server.deleteTask(task.id)
                self.refreshView()
            } catch {
                DispatchQueue.main.async {
                    self.stopLoading()
                }
                self.showAlert(Localized.deleteFailed)
            }
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
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editViewController: EditTaskViewController
        if let project {
            editViewController = EditTaskViewController(project: project, server: server, settings: settings)
        } else {
            editViewController = EditTaskViewController(server: server, settings: settings)
        }
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension TasksViewController: UITableViewDataSource {
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
}

extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = createTaskDetailViewController(for: tasks[indexPath.row], indexPath: indexPath)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func createTaskDetailViewController(for task: ProjectTask, indexPath: IndexPath) -> TaskDetailViewController {
        let currentProject: Project?
        var isContextProject = false
        
        if let project {
            currentProject = project
            isContextProject = true
        } else {
            currentProject = projects.first { $0.id == task.projectID }
        }
        
        let currentEmployee = employees.first { $0.id == task.employeeID }
        
        let detailViewController = TaskDetailViewController(
            indexPath: indexPath,
            task: task,
            project: currentProject,
            employee: currentEmployee,
            isContextProject: isContextProject,
            server: server,
            settings: settings)
        detailViewController.delegate = self
        detailViewController.deleteDelegate = self
        return detailViewController
    }
}

extension TasksViewController: ListUpdatable {
    var items: [ProjectTask] {
        get { tasks }
        set { tasks = newValue }
    }
    
    var emptyStateText: String {
        return Localized.noTasks
    }
}

extension TasksViewController: TasksViewControllerDelegate {
    func didAddTask(_ task: ProjectTask) {
        addItem(task)
    }
    
    func didUpdateTask(_ task: ProjectTask) {
        updateItem(task) { $0.id == task.id }
    }
}

extension TasksViewController: TaskDetailViewControllerDelegate {
    func didDeleteTask(_ task: ProjectTask, at indexPath: IndexPath) {
        performDelete(at: indexPath)
    }
}
