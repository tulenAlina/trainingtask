import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

final class ProjectsViewController: UIViewController {
    
    enum Mode {
        case normal
        case selection(completion: (Project) -> Void)
    }
    
    private let mode: Mode
    private let server: Server
    private let settings: SettingsManager
    private var projects: [Project] = []
    private var tableView: UITableView!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var refreshControl: UIRefreshControl!
    
    init(mode: Mode = .normal, server: Server, settings: SettingsManager) {
        self.mode = mode
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
        view.backgroundColor = .white
        title = Localized.Screen.projects.localized
        setupTableView()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        refreshControl = UIRefreshControl()
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
        switch mode {
        case .normal:
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItem = addButton
        case .selection:
            break
        }
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func loadProjects() async throws {
        let allProjects = try await server.fetchProjects()
        projects = Array(allProjects.prefix(settings.maxRecords))
        DispatchQueue.main.async {
            self.updateUIAfterLoading()
        }
    }
    
    private func updateUIAfterLoading() {
        tableView.reloadData()
        updateEmptyState()
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    private func updateEmptyState() {
        if projects.isEmpty {
            let label = UILabel()
            label.text = Localized.Empty.noProjects.localized
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
        let project = self.projects[indexPath.row]
        
        Task {
            do {
                try await self.server.deleteProject(project.id)
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
                self.showAlert(Localized.Error.deleteFailed.localized)
            }
        }
    }
    
    private func performEdit(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let project = self.projects[indexPath.row]
        let editViewController = EditProjectViewController(project: project, server: server)
        editViewController.delegate = self
        self.navigationController?.pushViewController(editViewController, animated: true)
        completion(true)
    }
    
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadProjects()
                await MainActor.run {
                    refreshControl.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert(Localized.Error.loadFailed.localized)
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editViewController = EditProjectViewController(server: server)
        editViewController.delegate = self
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        cell.textLabel?.text = projects[indexPath.row].projectName
        cell.detailTextLabel?.text = projects[indexPath.row].description
        return cell
    }
}

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch mode {
        case .normal:
            let deleteAction = createDeleteAction(at: indexPath)
            let editAction = createEditAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        case .selection:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        
        switch mode {
        case .normal:
            let tasksViewConttroller = TasksViewController(project: project, server: server, settings: settings)
            navigationController?.pushViewController(tasksViewConttroller, animated: true)
        case .selection(let completion):
            completion(project)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func createDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: Localized.Action.delete.localized) {[weak self] _,_,completion in
            self?.performDelete(at: indexPath, completion: completion)
        }
        return deleteAction
    }
    
    private func createEditAction(at indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .normal, title: Localized.Action.edit.localized) {[weak self] _,_,completion in
            self?.performEdit(at: indexPath, completion: completion)
        }
        return editAction
    }
}

extension ProjectsViewController: ProjectsViewControllerDelegate {
    private var lastRowIndexWithinLimit: Int {
        return settings.maxRecords - 1
    }

    private var lastIndexPathWithinLimit: IndexPath {
        return IndexPath(row: lastRowIndexWithinLimit, section: 0)
    }

    private var firstIndexPath: IndexPath {
        return IndexPath(row: 0, section: 0)
    }
    
    func didAddProject(_ project: Project) {
        let maxRecords = settings.maxRecords
        guard settings.maxRecords > 0 else { return }
        if projects.count >= maxRecords {
            projects.removeLast()
            tableView.deleteRows(at: [lastIndexPathWithinLimit], with: .automatic)
        }
        projects.insert(project, at: 0)
        tableView.insertRows(at: [firstIndexPath], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateProject(_ project: Project) {
        if let index = projects.firstIndex(where: {$0.id == project.id}) {
            projects[index] = project
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
