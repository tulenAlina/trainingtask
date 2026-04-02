import UIKit

final class ProjectsViewController: BaseListViewController<Project> {
    enum ProjectsDisplayMode {
        case list
        case selection(completion: (Project) -> Void)
    }
    
    private let server: Server
    private let mode: ProjectsDisplayMode
    
    override var emptyStateText: String {
        return Localized.noProjects
    }
    
    init(mode: ProjectsDisplayMode = .list, server: Server, settings: SettingsManager) {
        self.mode = mode
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
        setupNavigationTitle(Localized.projects)
        setupTableView()
        setupConstraints()
        setupNavigationBar()
        startLoading()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
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
    
    private func setupNavigationBar() {
        switch mode {
        case .list:
            addRightBarButton(systemItem: .add, action: #selector(addProject))
        case .selection:
            break
        }
    }
    
    private func loadProjects() async throws {
        let allProjects = try await server.fetchProjects()
        items = Array(allProjects.prefix(settings.maxRecords))
        await MainActor.run {
            tableView.reloadData()
            updateEmptyState()
            stopLoading()
            refreshControl.endRefreshing()
        }
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let project = items[indexPath.row]
        
        Task {
            do {
                try await server.deleteProject(project.id)
                refreshData()
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
                try await loadProjects()
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    @objc private func addProject() {
        let editViewController = EditProjectViewController(server: server, createDelegate: self)
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        cell.textLabel?.text = items[indexPath.row].projectName
        cell.detailTextLabel?.text = items[indexPath.row].description
        return cell
    }
}

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = items[indexPath.row]
        
        switch mode {
        case .list:
            let detailViewController = ProjectDetailViewController(indexPath: indexPath, project: project, server: server, settings: settings, updateDelegate: self, deleteDelegate: self)
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(project)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ProjectsViewController: ProjectUpdateDelegate {
    func didUpdateProject(_ project: Project) {
        updateItem(project) { $0.id == project.id }
    }
}

extension ProjectsViewController: ProjectCreateDelegate {
    func didCreateProject(_ project: Project) {
        addItem(project)
    }
}

extension ProjectsViewController: ProjectDeleteDelegate {
    func didDeleteProject(_ project: Project, at indexPath: IndexPath) {
        performDelete(at: indexPath)
    }
}
