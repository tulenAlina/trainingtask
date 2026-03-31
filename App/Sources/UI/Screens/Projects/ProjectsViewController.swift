import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

extension ProjectsViewControllerDelegate {
    func didAddProject(_ project: Project) {}
}

final class ProjectsViewController: UIViewController {
    
    enum Mode {
        case normal
        case selection(completion: (Project) -> Void)
    }
    
    let settings: SettingsManager
    let tableView = UITableView()
    
    private let server: Server
    private let mode: Mode
    private var projects: [Project] = []
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var refreshControl = UIRefreshControl()
    
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
        title = Localized.projects
        setupTableView()
        setupConstraints()
        setupNavigationBar()
        setupLoadingIndicator()
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
    
    private func performDelete(at indexPath: IndexPath) {
        self.loadingIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let project = self.projects[indexPath.row]
        
        Task {
            do {
                try await self.server.deleteProject(project.id)
                self.refreshView()
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
                self.showAlert(Localized.deleteFailed)
            }
        }
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
                    showAlert(Localized.loadFailed)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        
        switch mode {
        case .normal:
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
