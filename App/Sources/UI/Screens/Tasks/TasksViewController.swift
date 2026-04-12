import UIKit

final class TasksViewController: BaseListViewController<ProjectTask> {
    private let project: Project?
    private let server: Server
    private var projects: [Project] = []
    private var employees: [Employee] = []
        
    override var emptyStateText: String {
        return Localized.noTasks
    }
    
    init(project: Project? = nil, server: Server, settings: SettingsManager) {
        self.project = project
        self.server = server
        super.init(settings: settings)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshData()
    }
    
    private func setupUI() {
        setupNavigationBar(navigationTitle: Localized.tasks, rightButtonItem: .add, rightButtonAction: #selector(actionAddTask))
        setupTableView()
        startLoading()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func updateUI(){
        tableView.reloadData()
        updateEmptyState()
        stopLoading()
        refreshControl.endRefreshing()
    }
    
    private func loadTasks() async throws {
        async let allTasks = try await server.fetchTasks(projectID: project?.id)
        async let allEmployees = server.fetchEmployees()
        if project == nil {
            async let allProjects = server.fetchProjects()
            let (tasks, projects, employees) = try await (allTasks, allProjects, allEmployees)
            self.allItems = tasks
            self.projects = projects
            self.employees = employees
            self.displayedItems = Array(tasks.prefix(settings.maxRecords))
        } else {
            let (tasks, employees) = try await (allTasks, allEmployees)
            self.allItems = tasks
            self.employees = employees
            self.displayedItems = Array(tasks.prefix(settings.maxRecords))
        }
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let task = displayedItems[indexPath.row]

        Task {
            do {
                try await server.deleteTask(task.id)
                await MainActor.run {
                    allItems.remove(at: indexPath.row)
                    displayedItems = Array(allItems.prefix(settings.maxRecords))
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.deleteFailed)
                }
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            do {
                try await loadTasks()
                await MainActor.run {
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    @objc private func actionAddTask() {
        let editModuleViewController: UIViewController
        let onCreate = { [weak self] task in
            guard let self else { return }
            self.addItem(task)
        }
        
        if let project {
            editModuleViewController = EditTaskBuilder.build(
                project: project,
                server: server,
                settings: settings,
                onCreate: onCreate,
                onUpdate: nil
            )
        } else {
            editModuleViewController = EditTaskBuilder.build(
                project: project,
                server: server,
                settings: settings,
                onCreate: onCreate,
                onUpdate: nil)
        }
        navigationController?.pushViewController(editModuleViewController, animated: true)
    }
}

extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        let task = displayedItems[indexPath.row]
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
        let detailViewController = createTaskDetailViewController(for: displayedItems[indexPath.row], indexPath: indexPath)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func createTaskDetailViewController(for task: ProjectTask, indexPath: IndexPath) -> TaskDetailViewController {
        let currentProject: Project?
        var isOpenedFromProject = false
        
        if let project {
            currentProject = project
            isOpenedFromProject = true
        } else {
            currentProject = projects.first { $0.id == task.projectID }
        }
        
        let currentEmployee = employees.first { $0.id == task.employeeID }
        
        let detailViewController = TaskDetailViewController(
            indexPath: indexPath,
            task: task,
            project: currentProject,
            employee: currentEmployee,
            isOpenedFromProject: isOpenedFromProject,
            server: server,
            settings: settings,
            onUpdate: { [weak self] task in
                self?.updateItem(task) { $0.id == task.id }
            }, onDelete: { [weak self] indexPath in
                self?.performDelete(at: indexPath)
            }
        )
        return detailViewController
    }
}
