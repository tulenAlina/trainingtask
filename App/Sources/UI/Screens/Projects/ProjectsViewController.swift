import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

extension ProjectsViewControllerDelegate {
    func didAddProject(_ project: Project) {}
}

final class ProjectsViewController: BaseViewController {
    enum ProjectsDisplayMode {
        case list
        case selection(completion: (Project) -> Void)
    }
    
    let settings: SettingsManager
    let tableView = UITableView()
    
    private let server: Server
    private let mode: ProjectsDisplayMode
    private var projects: [Project] = []
    private var refreshControl = UIRefreshControl()
    
    init(mode: ProjectsDisplayMode = .list, server: Server, settings: SettingsManager) {
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
        projects = Array(allProjects.prefix(settings.maxRecords))
        await MainActor.run {
            self.updateUIAfterLoading()
        }
    }
    
    private func updateUIAfterLoading() {
        tableView.reloadData()
        updateEmptyState()
        stopLoading()
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let project = self.projects[indexPath.row]
        
        Task {
            do {
                try await self.server.deleteProject(project.id)
                self.refreshData()
            } catch {
                await MainActor.run {
                    self.stopLoading()
                }
                self.showAlert(Localized.deleteFailed)
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            do {
                try await loadProjects()
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
    
    @objc private func addProject() {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        
        switch mode {
        case .list:
            let detailViewController = ProjectDetailViewController(indexPath: indexPath, project: project, server: server, settings: settings)
            detailViewController.delegate = self
            detailViewController.deleteDelegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(project)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ProjectsViewController: ListUpdatable {
    var items: [Project] {
        get { projects }
        set { projects = newValue }
    }
    
    var emptyStateText: String {
        return Localized.noProjects
    }
}

extension ProjectsViewController: ProjectsViewControllerDelegate {
    func didAddProject(_ project: Project) {
        addItem(project)
    }
    
    func didUpdateProject(_ project: Project) {
        updateItem(project) { $0.id == project.id }
    }
}

extension ProjectsViewController: ProjectDetailViewControllerDelegate {
    func didDeleteProject(_ project: Project, at indexPath: IndexPath) {
        performDelete(at: indexPath)
    }
}
