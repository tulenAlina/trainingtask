import UIKit

final class ProjectsViewController: BaseListViewController<Project> {
    enum ProjectsDisplayMode {
        case list
        case selection
    }
    
    private let server: Server
    private let mode: ProjectsDisplayMode
    private let onSelectProject: ((Project) -> Void)?
    
    override var emptyStateText: String {
        return Localized.noProjects
    }
    
    init(server: Server, settings: SettingsManager) {
        self.mode = .list
        self.server = server
        self.onSelectProject = nil
        super.init(settings: settings)
    }
    
    init(server: Server, settings: SettingsManager, onSelectProject:  @escaping (Project) -> Void) {
        self.mode = .selection
        self.server = server
        self.onSelectProject = onSelectProject
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
        switch mode {
        case .list:
            setupNavigationBar(navigationTitle: Localized.projects, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddProject))
        case .selection:
            setupNavigationBar(navigationTitle: Localized.projects)
        }
        
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
    
    private func loadProjects() async throws {
        allItems = try await server.fetchProjects()
        displayedItems = Array(allItems.prefix(settings.maxRecords))
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let project = displayedItems[indexPath.row]
        
        Task {
            do {
                try await server.deleteProject(project.id)
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
                try await loadProjects()
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
    
    @objc private func actionAddProject() {
        let editViewController = EditProjectViewController(server: server, onCreate: { [weak self] project in
            self?.addItem(project)
        })
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        cell.textLabel?.text = displayedItems[indexPath.row].projectName
        cell.detailTextLabel?.text = displayedItems[indexPath.row].description
        return cell
    }
}

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = displayedItems[indexPath.row]
        
        switch mode {
        case .list:
            let detailViewController = ProjectDetailViewController(indexPath: indexPath, project: project, server: server, settings: settings, onUpdate: { [weak self] project in
                self?.updateItem(project) { $0.id == project.id }
            }, onDelete: { [weak self] indexPath in
                self?.performDelete(at: indexPath)
            })
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection:
            onSelectProject?(project)
            navigationController?.popViewController(animated: true)
        }
    }
}
