import UIKit

protocol ProjectSelectionOutputProtocol: AnyObject {
    func didSelectProject(_ project: Project)
}

final class ProjectsViewController: BaseListViewController<Project> {
    weak var selectionOutput: ProjectSelectionOutputProtocol?
    
    private let server: Server = AppDelegate.server
    private let settings: SettingsManager = AppDelegate.settings
    
    override var emptyStateText: String {
        Localized.noProjects
    }
    
    init(selectionOutput: ProjectSelectionOutputProtocol? = nil) {
        self.selectionOutput = selectionOutput
        super.init(settings: settings)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
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
}

// MARK: - UITableViewDataSource

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        let project = getItem(at: indexPath.row)
        cell.textLabel?.text = project.projectName
        cell.detailTextLabel?.text = project.description
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = getItem(at: indexPath.row)
        
        if let selectionOutput {
            selectionOutput.didSelectProject(project)
            navigationController?.popViewController(animated: true)
        } else {
            let detailViewController = ProjectDetailViewController(
                project: project,
                server: server,
                settings: settings,
                onUpdate: { [weak self] project in
                    self?.updateItem(project) { $0.id == project.id }
                },
                onDelete: { [weak self] projectID in
                    self?.deleteProject(with: projectID)
                }
            )
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

// MARK: - Private

private extension ProjectsViewController {
    func setupView() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        if selectionOutput == nil {
            super.setupNavigationBar(navigationTitle: Localized.projects, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddProject))
        } else {
            super.setupNavigationBar(navigationTitle: Localized.projects)
        }
    }
    
    func loadProjects() async throws {
        let items = try await server.fetchProjects()
        setItems(items)
    }
    
    func loadData() {
        startLoading()
        refreshData()
    }
    
    func deleteProject(with projectID: UUID) {
        startLoading()
        guard let index = firstIndex(where: { $0.id == projectID }) else { return }
        
        Task {
            do {
                try await server.deleteProject(projectID)
                await MainActor.run {
                    deleteItem(at: index)
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
    
    @objc func actionAddProject() {
        let editViewController = EditProjectViewController(server: server, action: .create({ [weak self] project in
            self?.addItem(project)
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
}
