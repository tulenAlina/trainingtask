import UIKit

final class ProjectsViewController: BaseListViewController<Project> {
    enum ProjectsDisplayMode {
        case list
        case selection(onSelect: (Project) -> Void)
    }
    
    private let server: Server
    private let settings: SettingsManager
    private let mode: ProjectsDisplayMode
    
    private var onSelectProject: ((Project) -> Void)? {
        if case .selection(let onSelect) = mode {
            return onSelect
        }
        return nil
    }
    
    override var emptyStateText: String {
        return Localized.noProjects
    }
    
    init(server: Server, settings: SettingsManager, mode: ProjectsDisplayMode = .list) {
        self.server = server
        self.settings = settings
        self.mode = mode
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
                try await loadProjects()
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
        setupNavigationBar()
        startLoading()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        switch mode {
        case .list:
            super.setupNavigationBar(navigationTitle: Localized.projects, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddProject))
        case .selection:
            super.setupNavigationBar(navigationTitle: Localized.projects)
        }
    }
    
    private func loadProjects() async throws {
        let items = try await server.fetchProjects()
        setItems(items)
    }
    
    private func deleteProject(at indexPath: IndexPath) {
        startLoading()
        let project = getItem(at: indexPath.row)
        
        Task {
            do {
                try await server.deleteProject(project.id)
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
    
    @objc private func actionAddProject() {
        let editViewController = EditProjectViewController(server: server, action: .create({ [weak self] project in
            self?.addItem(project)
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        let project = getItem(at: indexPath.row)
        cell.textLabel?.text = project.projectName
        cell.detailTextLabel?.text = project.description
        
        return cell
    }
}

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = getItem(at: indexPath.row)
        
        switch mode {
        case .list:
            let detailViewController = ProjectDetailViewController(indexPath: indexPath, project: project, server: server, settings: settings, onUpdate: { [weak self] project in
                self?.updateItem(project) { $0.id == project.id }
            }, onDelete: { [weak self] indexPath in
                self?.deleteProject(at: indexPath)
            })
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection:
            onSelectProject?(project)
            navigationController?.popViewController(animated: true)
        }
    }
}
