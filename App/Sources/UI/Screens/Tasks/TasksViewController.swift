import UIKit

final class TasksViewController: BaseListViewController<ProjectTask> {
    private let project: Project?
    private let server: Server
    private let settings: SettingsManager
    private var projects: [Project] = []
    private var employees: [Employee] = []
        
    override var emptyStateText: String {
        return Localized.noTasks
    }
    
    init(project: Project? = nil, server: Server, settings: SettingsManager) {
        self.project = project
        self.server = server
        self.settings = settings
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
    
    @objc override func refreshData() {
        Task {
            do {
                try await loadTasks()
                await MainActor.run {
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    private func setupUI() {
        setupNavigationBar(navigationTitle: Localized.tasks, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddTask))
        startLoading()
        setupTableView()
    }
   
    private func loadTasks() async throws {
        async let allTasks = try await server.fetchTasks(projectID: project?.id)
        async let allEmployees = server.fetchEmployees()
        if project == nil {
            async let allProjects = server.fetchProjects()
            let (tasks, projects, employees) = try await (allTasks, allProjects, allEmployees)
            setItems(tasks)
            self.projects = projects
            self.employees = employees
        } else {
            let (tasks, employees) = try await (allTasks, allEmployees)
            setItems(tasks)
            self.employees = employees
        }
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        startLoading()
        let task = getItem(at: indexPath.row)

        Task {
            do {
                try await server.deleteTask(task.id)
                await MainActor.run {
                    deleteItem(at: indexPath.row)
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

    @objc private func actionAddTask() {
        let editModuleViewController = EditTaskModule.build(moduleOutput: self)
        editModuleViewController.input.configureForCreate(project: project)
        navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}

extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        let task = getItem(at: indexPath.row)
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
        let task = getItem(at: indexPath.row)
        let detailViewController = createTaskDetailViewController(for: task, indexPath: indexPath)
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
            moduleOutput: self
        )
        
        return detailViewController
    }
}

extension TasksViewController: EditTaskModuleOutputProtocol {
    func didCreateTask(_ task: ProjectTask) {
        addItem(task)
    }
    
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?) {
        updateItem(task) { $0.id == task.id }
    }
}

extension TasksViewController: TaskDetailModuleOutputProtocol {
    func didDeleteTask(at indexPath: IndexPath) {
        deleteTask(at: indexPath)
    }
}
