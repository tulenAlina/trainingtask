import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func didAddTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask)
}

extension TasksViewControllerDelegate {
    func didAddTask(_ task: ProjectTask) {}
}

final class TasksViewController: UIViewController {
    private let project: Project?
    private let server = ServerManager.shared.currentServer
    private var tasks: [ProjectTask] = []
    private var projects: [Project] = []
    private var employees: [Employee] = []
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    init() {
        self.project = nil
        super.init(nibName: nil, bundle: nil)
    }
        
    init(project: Project) {
        self.project = project
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
        view.backgroundColor = .white
        title = "Задачи"
        setupTableView()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func loadTasks() async throws {
        let allTasks = try await server.fetchTasks(projectID: project?.id)
        if project == nil {
            projects = try await server.fetchProjects()
        }
        employees = try await server.fetchEmployees()
        tasks = Array(allTasks.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func performDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        self.loadingIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let task = self.tasks[indexPath.row]

        Task {
            do {
                try await self.server.deleteTask(task.id)
                self.refreshView()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    completion(false)
                }
                self.showAlert("Не удалось удалить задачу")
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
                    showAlert("Не удалось загрузить задачи")
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editViewController: EditTaskViewController
        if let project {
            editViewController = EditTaskViewController(project: project)
        } else {
            editViewController = EditTaskViewController()
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = createDeleteAction(at: indexPath)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = createTaskDetailViewController(for: tasks[indexPath.row])
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    private func createDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _,_,completion in
            self?.performDelete(at: indexPath, completion: completion)
        }
        return deleteAction
    }
    
    private func createTaskDetailViewController(for task: ProjectTask) -> TaskDetailViewController {
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
            task: task,
            project: currentProject,
            employee: currentEmployee,
            isContextProject: isContextProject)
        detailViewController.delegate = self
        return detailViewController
    }
}

extension TasksViewController: TasksViewControllerDelegate {
    func didAddTask(_ task: ProjectTask) {
        let maxRecords = SettingsManager.shared.maxRecords
        if tasks.count >= maxRecords {
            tasks.removeLast()
            tableView.deleteRows(at: [IndexPath(row: maxRecords - 1, section: 0)], with: .automatic)
        }
        tasks.insert(task, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateTask(_ task: ProjectTask) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks[index] = task
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
